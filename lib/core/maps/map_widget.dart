import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/location/location_service.dart';
import 'package:vental_go/core/location/default_location.dart';
import 'package:vental_go/core/geocoding/geocoding_service.dart';
import 'widgets/center_pin.dart';
import 'widgets/locate_me_button.dart';

class AppMapWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final double initialZoom;
  final bool showCenterPin;
  final bool showLocateButton;
  final List<LatLng>? routePoints;
  final void Function(MapLibreMapController controller)? onMapReady;
  final ValueChanged<LatLng>? onUserLocationFound;

  /// Вызывается при остановке движения карты (только если showCenterPin == true).
  /// Срабатывает дважды: сразу с address == null (координаты уже известны,
  /// адрес ещё грузится) и повторно, когда реверс-геокодинг завершится.
  final void Function(LatLng position, String? address)? onCenterChanged;

  const AppMapWidget({
    super.key,
    this.initialPosition,
    this.initialZoom = 15,
    this.showCenterPin = false,
    this.showLocateButton = true,
    this.routePoints,
    this.onMapReady,
    this.onUserLocationFound,
    this.onCenterChanged,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  MapLibreMapController? _controller;
  bool _styleLoaded = false;
  bool _locatingUser = false;
  Line? _routeLine;

  String? _centerAddress;
  bool _resolvingCenterAddress = false;
  int _centerRequestId = 0;

  static const String _customStyle = '''
  // ⚠️ НЕ УДАЛЯЙ — здесь остаётся твой текущий JSON стиля без изменений
  ''';

  @override
  void didUpdateWidget(AppMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routePoints != oldWidget.routePoints && _styleLoaded) {
      _updateRouteLine();
    }
  }

  Future<void> _updateRouteLine() async {
    final ctrl = _controller;
    if (ctrl == null) return;

    if (_routeLine != null) {
      await ctrl.removeLine(_routeLine!);
      _routeLine = null;
    }

    final points = widget.routePoints;
    if (points != null && points.length >= 2) {
      _routeLine = await ctrl.addLine(
        LineOptions(
          geometry: points,
          lineColor: '#0B4429',
          lineWidth: 4.5,
          lineOpacity: 0.9,
          lineJoin: 'round',
        ),
      );
    }
  }

  Future<void> _handleLocateMe() async {
    setState(() => _locatingUser = true);
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
      widget.onUserLocationFound?.call(position);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось получить геолокацию')),
      );
    } finally {
      if (mounted) setState(() => _locatingUser = false);
    }
  }

  Future<void> _resolveCenterAddress(LatLng position) async {
    if (!widget.showCenterPin) return;
    final requestId = ++_centerRequestId;

    setState(() {
      _resolvingCenterAddress = true;
      _centerAddress = null;
    });
    widget.onCenterChanged?.call(position, null);

    final address = await GeocodingService.reverseGeocode(position);
    if (!mounted || requestId != _centerRequestId) return;

    setState(() {
      _resolvingCenterAddress = false;
      _centerAddress = address;
    });
    widget.onCenterChanged?.call(position, address);
  }

  void _handleCameraIdle() {
    if (!widget.showCenterPin) return;
    final target = _controller?.cameraPosition?.target;
    if (target != null) _resolveCenterAddress(target);
  }

  @override
  Widget build(BuildContext context) {
    final startPosition = widget.initialPosition ?? DefaultLocation.center;

    return Stack(
      alignment: Alignment.center,
      children: [
        MapLibreMap(
          initialCameraPosition: CameraPosition(target: startPosition, zoom: widget.initialZoom),
          styleString: _customStyle,
          myLocationEnabled: false,
          trackCameraPosition: widget.showCenterPin,
          onMapCreated: (controller) => _controller = controller,
          onStyleLoadedCallback: () {
            setState(() => _styleLoaded = true);
            if (_controller != null) {
              widget.onMapReady?.call(_controller!);
              _updateRouteLine();
              if (widget.showCenterPin) {
                _resolveCenterAddress(startPosition);
              }
            }
          },
          onCameraIdle: _handleCameraIdle,
        ),
        if (widget.showCenterPin)
          CenterPin(isLoading: _resolvingCenterAddress, address: _centerAddress),
        if (!_styleLoaded)
          Container(
            color: AppColors.divider,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        if (widget.showLocateButton && _styleLoaded)
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(child: LocateMeButton(onTap: _handleLocateMe, isLoading: _locatingUser)),
          ),
      ],
    );
  }
}