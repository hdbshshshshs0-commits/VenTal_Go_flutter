import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import '../state/location_controller.dart';
import '../screens/address_map_screen.dart';

/// Bottom sheet for entering/confirming delivery address.
/// Has a text field + map button. Tapping map opens [AddressMapScreen].
Future<void> showAddressInputSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AddressInputSheet(),
  );
}

class _AddressInputSheet extends StatefulWidget {
  const _AddressInputSheet();

  @override
  State<_AddressInputSheet> createState() => _AddressInputSheetState();
}

class _AddressInputSheetState extends State<_AddressInputSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final loc = context.read<LocationController>();
    _ctrl = TextEditingController(text: loc.savedAddress);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openMap() async {
    final loc = context.read<LocationController>();
    if (loc.locationData == null) return;

    final result = await Navigator.of(context).push<(String, double, double)>(
      MaterialPageRoute(
        builder: (_) => AddressMapScreen(locationData: loc.locationData!),
        fullscreenDialog: true,
      ),
    );

    if (result != null && mounted) {
      final (address, lat, lng) = result;
      _ctrl.text = address;
      await loc.setAddress(address, lat, lng);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final loc = context.read<LocationController>();
    final data = loc.locationData;
    await loc.setAddress(text, data?.cityLat ?? 0, data?.cityLng ?? 0);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationController>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  loc.locationData != null ? '${loc.locationData!.cityName}, ${loc.locationData!.countryName}' : '',
                  style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Адрес доставки', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 4),
            const Text('Напр: ул. Абая, 130', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            const SizedBox(height: 12),
            // Address field + map button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'ул. Название улицы, дом',
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openMap,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _save,
                child: const Text('Сохранить', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
