import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class AitymRecommendationsScreen extends StatelessWidget {
  const AitymRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        title: Text(context.l10n.t('aitym_screen_title')),
      ),
      body: Center(child: Text(context.l10n.t('back'))),
    );
  }
}
