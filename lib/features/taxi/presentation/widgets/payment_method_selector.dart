import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/payment_method_model.dart';

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentMethodSelector({super.key, required this.selected, required this.onChanged});

  void _showDropdown(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu<PaymentMethod>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy - 8, position.dx + 200, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: PaymentMethod.values.map((method) {
        return PopupMenuItem<PaymentMethod>(
          value: method,
          child: Row(
            children: [
              Image.asset(method.iconPath, width: 22, height: 22),
              const SizedBox(width: 10),
              Text(context.l10n.t(method.stringKey)),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDropdown(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(selected.iconPath, width: 20, height: 20),
            const SizedBox(width: 8),
            Text(context.l10n.t(selected.stringKey), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }
}
