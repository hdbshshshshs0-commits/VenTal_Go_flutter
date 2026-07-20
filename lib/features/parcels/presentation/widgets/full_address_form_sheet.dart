import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/taxi/presentation/widgets/address_autocomplete_field.dart';
import '../../data/models/parcel_address_details_model.dart';

class FullAddressFormSheet extends StatefulWidget {
  final IconData icon;
  final String hintKey;
  final ParcelAddressDetails? initial;

  const FullAddressFormSheet({super.key, required this.icon, required this.hintKey, this.initial});

  static Future<ParcelAddressDetails?> show(
    BuildContext context, {
    required IconData icon,
    required String hintKey,
    ParcelAddressDetails? initial,
  }) {
    return showModalBottomSheet<ParcelAddressDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FullAddressFormSheet(icon: icon, hintKey: hintKey, initial: initial),
    );
  }

  @override
  State<FullAddressFormSheet> createState() => _FullAddressFormSheetState();
}

class _FullAddressFormSheetState extends State<FullAddressFormSheet> {
  String? _address;
  LatLng? _coordinates;
  final _entranceController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _intercomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _address = widget.initial!.address;
      _coordinates = widget.initial!.coordinates;
      _entranceController.text = widget.initial!.entrance;
      _floorController.text = widget.initial!.floor;
      _apartmentController.text = widget.initial!.apartment;
      _intercomController.text = widget.initial!.intercom;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _intercomController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_address == null || _coordinates == null) return;
    Navigator.of(context).pop(
      ParcelAddressDetails(
        address: _address!,
        coordinates: _coordinates!,
        entrance: _entranceController.text,
        floor: _floorController.text,
        apartment: _apartmentController.text,
        intercom: _intercomController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              AddressAutocompleteField(
                icon: widget.icon,
                hintKey: widget.hintKey,
                initialValue: _address,
                onAddressSelected: (address, coordinates) {
                  setState(() {
                    _address = address;
                    _coordinates = coordinates;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _detailField(_entranceController, 'parcel_entrance_hint')),
                  const SizedBox(width: 8),
                  Expanded(child: _detailField(_floorController, 'parcel_floor_hint')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _detailField(_apartmentController, 'parcel_apartment_hint')),
                  const SizedBox(width: 8),
                  Expanded(child: _detailField(_intercomController, 'parcel_intercom_hint')),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: (_address != null && _coordinates != null) ? _confirm : null,
                  child: Text(
                    context.l10n.t('address_confirm_button'),
                    style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailField(TextEditingController controller, String hintKey) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: context.l10n.t(hintKey), border: InputBorder.none, isDense: true),
      ),
    );
  }
}