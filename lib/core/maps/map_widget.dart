import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'widgets/center_pin.dart';

class AppMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final bool showCenterPin;
  final List<LatLng>? routePoints;
  final void Function(MapLibreMapController controller)? onMapReady;

  const AppMapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 15,
    this.showCenterPin = false,
    this.routePoints,
    this.onMapReady,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  MapLibreMapController? _controller;
  bool _styleLoaded = false;
  Line? _routeLine;

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
          lineColor: '#4A6CF7',
          lineWidth: 4.0,
          lineOpacity: 0.9,
          lineJoin: 'round',
        ),
      );
    }
  }

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
          styleString: '''
{
  "version": 8,
  "sources": {},
  "layers": [
    {
      "id": "background",
      "type": "background",
      "paint": {
        "background-color": "#ff0000"
      }
    }
  ]
}
''',
          myLocationEnabled: true,
          onMapCreated: (controller) => _controller = controller,
          onStyleLoadedCallback: () {
            setState(() => _styleLoaded = true);
            if (_controller != null) {
              widget.onMapReady?.call(_controller!);
              _updateRouteLine();
            }
          },
        ),
        if (widget.showCenterPin) const CenterPin(),
        if (!_styleLoaded)
          Container(
            color: AppColors.divider,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}
