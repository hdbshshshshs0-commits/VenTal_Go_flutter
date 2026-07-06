import 'package:flutter/material.dart';

/// Своё изображение пина — положить файл в assets/images/icons/center_pin.png
class CenterPin extends StatelessWidget {
  const CenterPin({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Image.asset('assets/images/icons/center_pin.png', width: 48, height: 64),
        ),
      ),
    );
  }
}
