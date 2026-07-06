import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/widgets/phone_input_field.dart';
import '../../data/models/parcel_contact_model.dart';

/// Универсальная форма контакта — используется и для отправителя, и для
/// получателя. showDetailFields=false скрывает этаж/квартиру/домофон
/// (режим "здание до здания"). showDetailFields всегда true для формы
/// получателя, если у отправителя выбрано "от двери до двери".
class ParcelContactForm extends StatefulWidget {
  final String titleKey;
  final bool showDetailFields;
  final ValueChanged<ParcelContactModel> onChanged;

  const ParcelContactForm({
    super.key,
    required this.titleKey,
    required this.showDetailFields,
    required this.onChanged,
  });

  @override
  State<ParcelContactForm> createState() => _ParcelContactFormState();
}

class _ParcelContactFormState extends State<ParcelContactForm> {
  final _name = TextEditingController();
  String _phone = '';
  final _address = TextEditingController();
  final _entrance = TextEditingController();
  final _floor = TextEditingController();
  final _apartment = TextEditingController();
  final _intercom = TextEditingController();
  final _comment = TextEditingController();

  void _emit() {
    widget.onChanged(ParcelContactModel(
      name: _name.text,
      phone: _phone,
      address: _address.text,
      entrance: widget.showDetailFields ? _entrance.text : null,
      floor: widget.showDetailFields ? _floor.text : null,
      apartment: widget.showDetailFields ? _apartment.text : null,
      intercomCode: widget.showDetailFields ? _intercom.text : null,
      comment: _comment.text,
    ));
  }

  Widget _field(TextEditingController controller, String hintKey, {int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines ?? 1,
        onChanged: (_) => _emit(),
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
  void dispose() {
    for (final c in [_name, _address, _entrance, _floor, _apartment, _intercom, _comment]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.t(widget.titleKey), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
        const SizedBox(height: 12),
        _field(_name, 'parcel_name_hint'),
        PhoneInputField(onChanged: (v) { _phone = v; _emit(); }),
        const SizedBox(height: 8),
        _field(_address, 'parcel_address_hint'),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: widget.showDetailFields
              ? Column(
                  children: [
                    Row(children: [
                      Expanded(child: _field(_entrance, 'parcel_entrance_hint')),
                      const SizedBox(width: 8),
                      Expanded(child: _field(_floor, 'parcel_floor_hint')),
                      const SizedBox(width: 8),
                      Expanded(child: _field(_apartment, 'parcel_apartment_hint')),
                    ]),
                    _field(_intercom, 'parcel_intercom_hint'),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        _field(_comment, 'parcel_comment_hint', maxLines: 2),
      ],
    );
  }
}
