import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/location/location_service.dart';
import '../widgets/online_offline_toggle.dart';
import '../widgets/incoming_order_card.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  LatLng? _driverPosition;
  bool isOnline = false;
  bool isSearchingOrder = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _driverPosition = position);
    } catch (_) {}
  }

  void _onToggleOnline(bool value) {
    setState(() {
      isOnline = value;
      isSearchingOrder = value;
    });
    if (value) {
      Future.delayed(const Duration(seconds: 2), _showIncomingOrder);
    }
  }

  void _showIncomingOrder() {
    if (!mounted || !isOnline) return;
    setState(() => isSearchingOrder = false);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => IncomingOrderCard(
        fromAddress: 'ул. Мангилик Ел, 28',
        toAddress: 'ул. Кабанбай батыра, 15',
        driverEarnings: 890,
        onAccept: () => Navigator.pop(context),
        onDecline: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: _driverPosition == null
                ? Container(color: AppColors.divider, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)))
                : AppMapWidget(initialPosition: _driverPosition!),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OnlineOfflineToggle(onChanged: _onToggleOnline),
                  if (isSearchingOrder)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 8),
                          Text(context.l10n.t('driver_searching_order'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
