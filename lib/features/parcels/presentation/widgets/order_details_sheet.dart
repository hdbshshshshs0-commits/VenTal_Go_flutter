import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class ParcelOrderDetails {
  final String description;
  final String comment;
  final File photo;
  final bool isFragile;
  final bool doorToDoor;
  final String paymentMethod; // 'card' | 'cash'

  const ParcelOrderDetails({
    required this.description,
    required this.comment,
    required this.photo,
    required this.isFragile,
    required this.doorToDoor,
    required this.paymentMethod,
  });
}

class OrderDetailsSheet extends StatefulWidget {
  final ParcelOrderDetails? initial;

  const OrderDetailsSheet({super.key, this.initial});

  static Future<ParcelOrderDetails?> show(BuildContext context, {ParcelOrderDetails? initial}) {
    return showModalBottomSheet<ParcelOrderDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderDetailsSheet(initial: initial),
    );
  }

  @override
  State<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {
  final _descriptionController = TextEditingController();
  final _commentController = TextEditingController();
  File? _photo;
  bool _isFragile = false;
  bool _doorToDoor = false;
  String _paymentMethod = 'card';

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _descriptionController.text = widget.initial!.description;
      _commentController.text = widget.initial!.comment;
      _photo = widget.initial!.photo;
      _isFragile = widget.initial!.isFragile;
      _doorToDoor = widget.initial!.doorToDoor;
      _paymentMethod = widget.initial!.paymentMethod;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(void Function(void Function()) setModalState) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setModalState(() => _photo = File(picked.path));
  }

  bool get _canProceed => _descriptionController.text.trim().isNotEmpty && _photo != null;

  void _submit() {
    if (!_canProceed) return;
    Navigator.of(context).pop(
      ParcelOrderDetails(
        description: _descriptionController.text.trim(),
        comment: _commentController.text.trim(),
        photo: _photo!,
        isFragile: _isFragile,
        doorToDoor: _doorToDoor,
        paymentMethod: _paymentMethod,
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
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.t('parcel_details_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark)),
                      IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(context.l10n.t('parcel_whats_inside'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 200,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: context.l10n.t('parcel_whats_inside_hint'),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(context.l10n.t('parcel_comment_hint'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _commentController,
                    maxLines: 2,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: context.l10n.t('parcel_comment_example'),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(context.l10n.t('parcel_photo_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pickPhoto(setModalState),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: _photo != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(_photo!, fit: BoxFit.cover))
                          : const Icon(Icons.camera_alt_outlined, color: AppColors.textHint, size: 28),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.t('parcel_fragile_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text(context.l10n.t('parcel_fragile_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    value: _isFragile,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setModalState(() => _isFragile = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.t('parcel_delivery_door_to_door'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    value: _doorToDoor,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setModalState(() => _doorToDoor = v),
                  ),
                  const SizedBox(height: 8),
                  Text(context.l10n.t('taxi_choose_payment'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  _paymentOption(setModalState, 'card', Icons.credit_card_rounded, context.l10n.t('payment_card')),
                  const SizedBox(height: 8),
                  _paymentOption(setModalState, 'cash', Icons.payments_outlined, context.l10n.t('payment_cash')),
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
                      onPressed: _canProceed ? _submit : null,
                      child: Text(
                        context.l10n.t('address_confirm_button'),
                        style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _paymentOption(void Function(void Function()) setModalState, String value, IconData icon, String label) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setModalState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isSelected ? AppColors.primary : AppColors.textHint),
          ],
        ),
      ),
    );
  }
}