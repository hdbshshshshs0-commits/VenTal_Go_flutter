import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

class ProfileSectionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileSectionItem({required this.icon, required this.label, required this.onTap});
}

class ProfileSectionGroup extends StatelessWidget {
  final List<ProfileSectionItem> items;

  const ProfileSectionGroup({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            ListTile(
              leading: Icon(items[i].icon, color: AppColors.textDark, size: 22),
              title: Text(
                items[i].label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              onTap: items[i].onTap,
            ),
            if (i != items.length - 1) const Divider(height: 1, indent: 56),
          ],
        ],
      ),
    );
  }
}