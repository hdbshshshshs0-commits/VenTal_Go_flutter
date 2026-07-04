import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'widgets/center_pin.dart';

class AppMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final bool showCenterPin;
  final void Function(MapLibreMapController controller)? onMapReady;

  const AppMapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 15,
    this.showCenterPin = false,
    this.onMapReady,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  MapLibreMapController? _controller;
  bool _styleLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MapLibreMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: widget.initialZoom,
          ),
          styleString: 'asset://assets/map/style.json',
          onMapCreated: (controller) => _controller = controller,
          onStyleLoadedCallback: () {
            setState(() => _styleLoaded = true);
            if (_controller != null) widget.onMapReady?.call(_controller!);
          },
        ),
        if (widget.showCenterPin) const CenterPin(),
        if (!_styleLoaded)
          Container(
            color: AppColorsStub.divider,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}

/// Локальный алиас, чтобы не тянуть весь AppColors в core/maps (избегаем
/// циклической зависимости между core-подпапками). Значение совпадает
/// с AppColors.divider.
class AppColorsStub {
  static const Color divider = Color(0xFFE5E7EB);
}