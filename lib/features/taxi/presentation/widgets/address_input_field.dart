import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

class AddressInputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  const AddressInputField({super.key, required this.icon, required this.hint, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(hintText: hint, border: InputBorder.none, isDense: true),
            ),
          ),
        ],
      ),
    );
  }
}
