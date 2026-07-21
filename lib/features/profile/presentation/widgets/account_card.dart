import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';
import 'package:vental_go/features/auth/data/models/user_role.dart';
import 'package:vental_go/features/auth/data/models/user_role_style.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final role = user?.role ?? UserRole.client;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: role.profileGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white.withValues(alpha: 0.35),
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {}, // TODO: загрузка фото профиля
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.add_rounded, size: 16, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? '—',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.phone ?? '—',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.t(role.profileLabelKey),
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}