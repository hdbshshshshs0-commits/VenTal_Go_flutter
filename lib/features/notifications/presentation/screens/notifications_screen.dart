import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Уведомления',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark),
        ),
        centerTitle: false,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.divider),
            SizedBox(height: 16),
            Text(
              'Нет уведомлений',
              style: TextStyle(fontSize: 16, color: AppColors.textHint, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Здесь будут уведомления от VenTal',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
