import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/payment_method_model.dart';

class PaymentMethodSheet extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;
  final VoidCallback onAddCard;

  const PaymentMethodSheet({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onAddCard,
  });

  static Future<void> show(
    BuildContext context, {
    required PaymentMethod selected,
    required ValueChanged<PaymentMethod> onChanged,
    required VoidCallback onAddCard,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PaymentMethodSheet(selected: selected, onChanged: onChanged, onAddCard: onAddCard),
    );
  }

  static const _otherMethods = [PaymentMethod.cash, PaymentMethod.kaspiTransfer, PaymentMethod.halykTransfer];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
          Text(
            context.l10n.t('payment_methods_title'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          ..._otherMethods.map((method) => _methodTile(context, method)),
          const SizedBox(height: 16),
          Text(
            context.l10n.t('payment_methods_cards'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textHint),
          ),
          const SizedBox(height: 8),
          _methodTile(context, PaymentMethod.card),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            title: Text(
              context.l10n.t('payment_add_card'),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary),
            ),
            onTap: () {
              Navigator.of(context).pop();
              onAddCard();
            },
          ),
        ],
      ),
    );
  }

  Widget _methodTile(BuildContext context, PaymentMethod method) {
    final isSelected = method == selected;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.asset(method.iconPath, width: 26, height: 26),
      title: Text(
        context.l10n.t(method.stringKey),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      onTap: () {
        onChanged(method);
        Navigator.of(context).pop();
      },
    );
  }
}
