import 'package:flutter/material.dart';
import '../../data/models/payment_method_model.dart';
import 'payment_method_sheet.dart';

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;
  final VoidCallback? onAddCard;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PaymentMethodSheet.show(
        context,
        selected: selected,
        onChanged: onChanged,
        onAddCard: onAddCard ?? () {}, // TODO: подключить реальный флоу добавления карты
      ),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          selected.iconPath,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
