import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

/// Плавающая круглая кнопка на карте — запрашивает геолокацию по нажатию,
/// а не блокирует загрузку карты автоматическим запросом при открытии экрана.
class LocateMeButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const LocateMeButton({super.key, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: isLoading
              ? const Padding(padding: EdgeInsets.all(13), child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}
