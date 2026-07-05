import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class CourierSoundSettingsScreen extends StatefulWidget {
  const CourierSoundSettingsScreen({super.key});

  @override
  State<CourierSoundSettingsScreen> createState() => _CourierSoundSettingsScreenState();
}

class _CourierSoundSettingsScreenState extends State<CourierSoundSettingsScreen> {
  int _selectedIndex = 0;
  final List<String> _labelKeys = ['courier_sound_option_1', 'courier_sound_option_2', 'courier_sound_option_3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('courier_sound_settings_title')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _labelKeys.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.music_note_rounded, color: isSelected ? AppColors.primary : AppColors.textDark),
                const SizedBox(width: 12),
                Expanded(child: Text(context.l10n.t(_labelKeys[index]), style: const TextStyle(fontWeight: FontWeight.w600))),
                TextButton(
                  onPressed: () {},
                  child: Text(context.l10n.t('courier_sound_play')),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = index),
                  child: Text(
                    context.l10n.t('courier_sound_select'),
                    style: TextStyle(color: isSelected ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
