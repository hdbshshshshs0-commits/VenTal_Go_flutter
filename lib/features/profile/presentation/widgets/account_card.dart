import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';
import 'package:vental_go/features/auth/data/models/user_role.dart';
import 'package:vental_go/features/auth/data/models/user_role_style.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    if (context.mounted) {
      await context.read<AuthController>().updateAvatar(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final role = user?.role ?? UserRole.client;

    return Container(
      decoration: BoxDecoration(
        gradient: role.profileGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Top row: avatar + name/phone/email + role
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with picker
                GestureDetector(
                  onTap: () => _pickAvatar(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        backgroundImage: user?.avatarPath != null
                            ? FileImage(File(user!.avatarPath!))
                            : null,
                        child: user?.avatarPath == null
                            ? const Icon(Icons.person, color: Colors.white, size: 44)
                            : null,
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
                            onTap: () => _pickAvatar(context),
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.add_rounded, size: 15, color: Color(0xFF333333)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Name / phone / email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name.isNotEmpty == true ? user!.name : 'No name',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phone.isNotEmpty == true ? user!.phone : '—',
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      if (user?.email != null && user!.email!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          user.email!,
                          style: const TextStyle(fontSize: 13, color: Colors.white60),
                        ),
                      ],
                    ],
                  ),
                ),
                // Role badge
                Text(
                  context.l10n.t(role.profileLabelKey),
                  style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
