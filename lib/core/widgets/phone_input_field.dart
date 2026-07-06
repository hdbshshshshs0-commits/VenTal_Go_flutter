import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Маска ввода телефона: +7 ХХХ ХХХ ХХХХ.
/// Используется везде в приложении, где вводится номер телефона
/// (регистрация, посылки — отправитель/получатель, профиль).
class PhoneInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const PhoneInputField({super.key, required this.onChanged, this.initialValue});

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 10 ? digits.substring(0, 10) : digits;

    final buffer = StringBuffer('+7 ');
    for (int i = 0; i < trimmed.length; i++) {
      buffer.write(trimmed[i]);
      if (i == 2 || i == 5) buffer.write(' ');
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '+7 ');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [_PhoneMaskFormatter()],
      onChanged: (value) {
        final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
        widget.onChanged('+$digitsOnly');
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
