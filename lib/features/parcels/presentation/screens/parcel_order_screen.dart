import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/main_hub/presentation/screens/main_hub_screen.dart';
import '../../data/models/parcel_model.dart';
import '../../data/pricing/parcel_pricing_calculator.dart';
import '../widgets/parcel_category_selector.dart';
import '../widgets/parcel_delivery_type_toggle.dart';
import '../widgets/parcel_contact_form.dart';

class ParcelOrderScreen extends StatefulWidget {
  const ParcelOrderScreen({super.key});

  @override
  State<ParcelOrderScreen> createState() => _ParcelOrderScreenState();
}

class _ParcelOrderScreenState extends State<ParcelOrderScreen> {
  ParcelCategory _category = ParcelCategory.upTo5kg;
  ParcelDeliveryType _deliveryType = ParcelDeliveryType.toAddress;

  final _senderName = TextEditingController();
  final _senderPhone = TextEditingController();
  final _senderAddress = TextEditingController();
  final _senderEntrance = TextEditingController();
  final _senderFloor = TextEditingController();
  final _senderApartment = TextEditingController();

  final _receiverName = TextEditingController();
  final _receiverPhone = TextEditingController();
  final _receiverAddress = TextEditingController();
  final _receiverEntrance = TextEditingController();
  final _receiverFloor = TextEditingController();
  final _receiverApartment = TextEditingController();

  final _commentController = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _senderName, _senderPhone, _senderAddress, _senderEntrance, _senderFloor, _senderApartment,
      _receiverName, _receiverPhone, _receiverAddress, _receiverEntrance, _receiverFloor, _receiverApartment,
      _commentController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _placeOrder() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainHubScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final price = ParcelPricingCalculator.calculate(category: _category, deliveryType: _deliveryType);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('parcel_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          ParcelCategorySelector(selected: _category, onChanged: (v) => setState(() => _category = v)),
          const SizedBox(height: 20),
          ParcelDeliveryTypeToggle(selected: _deliveryType, onChanged: (v) => setState(() => _deliveryType = v)),
          const SizedBox(height: 24),
          ParcelContactForm(
            titleKey: 'parcel_sender_title',
            nameController: _senderName,
            phoneController: _senderPhone,
            addressController: _senderAddress,
            entranceController: _senderEntrance,
            floorController: _senderFloor,
            apartmentController: _senderApartment,
          ),
          const SizedBox(height: 24),
          ParcelContactForm(
            titleKey: 'parcel_receiver_title',
            nameController: _receiverName,
            phoneController: _receiverPhone,
            addressController: _receiverAddress,
            entranceController: _receiverEntrance,
            floorController: _receiverFloor,
            apartmentController: _receiverApartment,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.t('parcel_comment_hint'),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _placeOrder,
              child: Text(
                '${context.l10n.t('parcel_order_button')} $price тг',
                style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
