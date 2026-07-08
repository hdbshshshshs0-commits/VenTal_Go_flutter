import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';
import 'package:vental_go/features/auth/presentation/screens/login_screen.dart';
import '../widgets/account_card.dart';
import '../widgets/profile_section_card.dart';
import 'addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthController>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handleSectionTap(String key) {
    switch (key) {
      case 'profile_section_addresses':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddressesScreen()),
        );
        break;
      default:
        // TODO: остальные переходы (account, payment, history, settings, support)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      (icon: Icons.person_outline_rounded, key: 'profile_section_account'),
      (icon: Icons.location_on_outlined, key: 'profile_section_addresses'),
      (icon: Icons.payment_rounded, key: 'profile_section_payment'),
      (icon: Icons.receipt_long_outlined, key: 'profile_section_history'),
      (icon: Icons.settings_outlined, key: 'profile_section_settings'),
      (icon: Icons.support_agent_rounded, key: 'profile_section_support'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('profile_title')),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AccountCard(),
            const SizedBox(height: 20),
            ...sections.map((s) => ProfileSectionCard(
                  icon: s.icon,
                  label: context.l10n.t(s.key),
                  onTap: () => _handleSectionTap(s.key),
                )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(context.l10n.t('profile_logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}