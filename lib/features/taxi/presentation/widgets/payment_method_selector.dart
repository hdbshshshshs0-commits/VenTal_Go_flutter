import 'package:flutter/material.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/payment_method_model.dart';

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  void _showDropdown(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu<PaymentMethod>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 8,
        position.dx + 200,
        position.dy + size.height,
      ),
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
