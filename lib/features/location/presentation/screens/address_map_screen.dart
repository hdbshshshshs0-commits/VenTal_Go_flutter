import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import '../../data/models/location_country_data.dart';
import '../../data/services/geocoding_service.dart';
import '../widgets/center_pin_widget.dart';

/// Full-screen map for choosing a delivery address via center-pin.
/// Returns the confirmed (address, lat, lng) or null if cancelled.
class AddressMapScreen extends StatefulWidget {
  final LocationData locationData;

  const AddressMapScreen({super.key, required this.locationData});

  @override
  State<AddressMapScreen> createState() => _AddressMapScreenState();
}

class _AddressMapScreenState extends State<AddressMapScreen> {
  MapLibreMapController? _mapController;
  String? _currentAddress;
  bool _isSearching = false;
  double _currentLat = 0;
  double _currentLng = 0;
  Timer? _geocodeDebounce;
  bool _cameraMoving = false;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.locationData.savedLat ?? widget.locationData.cityLat;
    _currentLng = widget.locationData.savedLng ?? widget.locationData.cityLng;
    _currentAddress = widget.locationData.savedAddress;
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  // Called continuously while camera is moving — use to mark "searching"
  void _onCameraMove(CameraPosition position) {
    if (!_cameraMoving) {
      _cameraMoving = true;
      _geocodeDebounce?.cancel();
      if (mounted) {
        setState(() {
          _isSearching = true;
          _currentAddress = null;
        });
      }
    }
  }

  // Called once camera comes to rest — geocode the final position
  void _onCameraIdle() {
    _cameraMoving = false;
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 400), () async {
      final pos = _mapController?.cameraPosition;
      if (pos == null) return;

      final lat = pos.target.latitude;
      final lng = pos.target.longitude;
      _currentLat = lat;
      _currentLng = lng;

      if (!mounted) return;
      setState(() => _isSearching = true);

      final address = await GeocodingService.reverseGeocode(lat, lng);
      if (!mounted) return;
      setState(() {
        _currentAddress = address;
        _isSearching = false;
      });
    });
  }

  void _save() {
    if (_currentAddress == null) return;
    Navigator.pop(context, (_currentAddress!, _currentLat, _currentLng));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // ── Top bar ───────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _isSearching
                            ? 'Ищем адрес...'
                            : (_currentAddress ?? 'Переместите карту'),
                        style: TextStyle(
                          fontSize: 14,
                          color: _currentAddress != null && !_isSearching
                              ? Colors.black87
                              : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Center pin ────────────────────────────────────────────────────
          Center(
            child: CenterPinWidget(
              address: _currentAddress,
              isSearching: _isSearching,
            ),
          ),

          // ── Save button ───────────────────────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed:
                      (_currentAddress != null && !_isSearching) ? _save : null,
                  child: const Text(
                    'Сохранить адрес',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
