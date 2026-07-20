import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/parcel_address_details_model.dart';
import '../widgets/parcel_address_field.dart';
import '../widgets/order_details_sheet.dart';
import 'delivery_selection_screen.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  ParcelAddressDetails? _fromAddress;
  ParcelAddressDetails? _toAddress;
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  ParcelOrderDetails? _orderDetails;

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    super.dispose();
  }

  bool get _canProceed =>
      _fromAddress != null &&
      _toAddress != null &&
      _senderNameController.text.trim().isNotEmpty &&
      _senderPhoneController.text.trim().isNotEmpty &&
      _receiverNameController.text.trim().isNotEmpty &&
      _receiverPhoneController.text.trim().isNotEmpty &&
      _orderDetails != null;

  Future<void> _openOrderDetails() async {
    final result = await OrderDetailsSheet.show(context, initial: _orderDetails);
    if (result != null) setState(() => _orderDetails = result);
  }

  void _proceed() {
    if (!_canProceed) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliverySelectionScreen(
          fromAddress: _fromAddress!,
          toAddress: _toAddress!,
          orderDetails: _orderDetails!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.textDark),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(context.l10n.t('parcel_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.textDark)),
            const SizedBox(height: 20),
            _sectionCard(
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(context.l10n.t('taxi_from'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                ParcelAddressField(
                  icon: Icons.trip_origin,
                  hintKey: 'parcel_address_hint',
                  value: _fromAddress,
                  onChanged: (v) => setState(() => _fromAddress = v),
                ),
                const SizedBox(height: 14),
                Text(context.l10n.t('parcel_sender_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textHint)),
                const SizedBox(height: 6),
                _textField(_senderNameController, 'parcel_name_hint', Icons.person_outline_rounded),
                const SizedBox(height: 8),
                _textField(_senderPhoneController, 'parcel_phone_hint', Icons.call_outlined, keyboardType: TextInputType.phone),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(context.l10n.t('taxi_to'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                ParcelAddressField(
                  icon: Icons.location_on,
                  hintKey: 'parcel_address_hint',
                  value: _toAddress,
                  onChanged: (v) => setState(() => _toAddress = v),
                ),
                const SizedBox(height: 14),
                Text(context.l10n.t('parcel_receiver_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textHint)),
                const SizedBox(height: 6),
                _textField(_receiverNameController, 'parcel_name_hint', Icons.person_outline_rounded),
                const SizedBox(height: 8),
                _textField(_receiverPhoneController, 'parcel_phone_hint', Icons.call_outlined, keyboardType: TextInputType.phone),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _openOrderDetails,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.list_alt_rounded, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.t('parcel_details_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                          Text(
                            _orderDetails != null ? context.l10n.t('parcel_details_filled') : context.l10n.t('parcel_details_subtitle'),
                            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _canProceed ? _proceed : null,
                child: Text(context.l10n.t('parcel_next_button'), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _textField(TextEditingController controller, String hintKey, IconData icon, {TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: context.l10n.t(hintKey), border: InputBorder.none, isDense: true),
            ),
          ),
        ],
      ),
    );
  }
}