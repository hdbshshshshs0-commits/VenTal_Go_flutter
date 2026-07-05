import 'package:flutter/material.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class ParcelContactForm extends StatelessWidget {
  final String titleKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController entranceController;
  final TextEditingController floorController;
  final TextEditingController apartmentController;

  const ParcelContactForm({
    super.key,
    required this.titleKey,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.entranceController,
    required this.floorController,
    required this.apartmentController,
  });

  Widget _field(String hintKey, TextEditingController ctrl, BuildContext context, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: context.l10n.t(hintKey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.t(titleKey), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 12),
        _field('parcel_name_hint', nameController, context),
        _field('parcel_phone_hint', phoneController, context, keyboardType: TextInputType.phone),
        _field('parcel_address_hint', addressController, context),
        Row(
          children: [
            Expanded(child: _field('parcel_entrance_hint', entranceController, context, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _field('parcel_floor_hint', floorController, context, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _field('parcel_apartment_hint', apartmentController, context, keyboardType: TextInputType.number)),
          ],
        ),
      ],
    );
  }
}
