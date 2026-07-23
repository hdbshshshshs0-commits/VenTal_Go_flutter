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
  MaplibreMapController? _mapController;
  String? _currentAddress;
  bool _isSearching = false;
  double _currentLat = 0;
  double _currentLng = 0;
  Timer? _geocodeDebounce;

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

  void _onMapCreated(MaplibreMapController controller) {
    _mapController = controller;
  }

  void _onCameraIdle() {
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 600), () async {
      final center = await _mapController?.cameraPosition;
      if (center == null) return;

      final lat = center.target.latitude;
      final lng = center.target.longitude;
      _currentLat = lat;
      _currentLng = lng;

      setState(() => _isSearching = true);

      final address = await GeocodingService.reverseGeocode(lat, lng);
      if (!mounted) return;
      setState(() {
        _currentAddress = address;
        _isSearching = false;
      });
    });
  }

  void _onCameraMoveStarted() {
    _geocodeDebounce?.cancel();
    setState(() {
      _isSearching = true;
      _currentAddress = null;
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
          // Map
          MaplibreMap(
            styleString: 'assets/map/style.json',
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentLat, _currentLng),
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
            onCameraIdle: _onCameraIdle,
            onCameraMoveStarted: _onCameraMoveStarted,
            trackCameraPosition: true,
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.none,
          ),

          // Top bar
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
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 8)],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8)],
                      ),
                      child: Text(
                        _currentAddress ?? 'Ищем адрес...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _currentAddress != null ? AppColors.textDark : AppColors.textHint,
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

          // Center pin — always in the visual center of the map
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CenterPinWidget(
                  address: _currentAddress,
                  isSearching: _isSearching,
                ),
                // Offset upward by half pin height so dot sits at map center
                const SizedBox(height: 0),
              ],
            ),
          ),

          // Save button
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  onPressed: (_currentAddress != null && !_isSearching) ? _save : null,
                  child: const Text(
                    'Сохранить адрес',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
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
