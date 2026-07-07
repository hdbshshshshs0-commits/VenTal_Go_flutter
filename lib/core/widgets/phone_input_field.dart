import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vental_go/core/theme/app_colors.dart';

class PhoneInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const PhoneInputField({super.key, required this.onChanged});

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

/// Форматтер группирует цифры как 3-3-2-2 (700 123 45 01) — привычный
/// для Казахстана вид номера. Отдельно отличает "удалили цифру" от
/// "удалили автоматический пробел маски", чтобы Backspace на границе
/// группы не выглядел так, будто ничего не удаляется.
class _LocalPhoneMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    final newDigitsRaw = newValue.text.replaceAll(RegExp(r'\D'), '');

    final isDeleting = newValue.text.length < oldValue.text.length;
    final onlySpaceWasRemoved = isDeleting && newDigitsRaw.length == oldDigits.length;

    String digits;
    if (onlySpaceWasRemoved && oldDigits.isNotEmpty) {
      digits = oldDigits.substring(0, oldDigits.length - 1);
    } else {
      digits = newDigitsRaw.length > 10 ? newDigitsRaw.substring(0, 10) : newDigitsRaw;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 2 || i == 5 || i == 7) buffer.write(' ');
    }

    final text = buffer.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    widget.onChanged(digits.isEmpty ? '' : '+7$digits');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Text('+7', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: AppColors.divider),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: false,
              keyboardType: TextInputType.number,
              inputFormatters: [_LocalPhoneMaskFormatter()],
              onChanged: _handleChanged,
              decoration: const InputDecoration(
                hintText: '___ ___ __ __',
                hintStyle: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}