import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: AppColors.accent, child: Icon(Icons.person, color: AppColors.primary, size: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? '—', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(user?.phone ?? '—', style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {}, // TODO: заглушка редактирования профиля
            child: Text(context.l10n.t('profile_edit'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
