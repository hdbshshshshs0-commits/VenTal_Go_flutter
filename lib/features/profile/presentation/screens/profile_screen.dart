import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';
import 'package:vental_go/features/auth/presentation/screens/login_screen.dart';
import '../widgets/account_card.dart';
import '../widgets/profile_section_group.dart';
import '../widgets/partner_promo_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110), // запас снизу под плавающий навбар
            children: [
              const AccountCard(),
              const SizedBox(height: 20),
              ProfileSectionGroup(items: [
                ProfileSectionItem(
                  icon: Icons.person_outline_rounded,
                  label: context.l10n.t('profile_section_account'),
                  onTap: () {}, // TODO: экран аккаунта
                ),
                ProfileSectionItem(
                  icon: Icons.location_on_outlined,
                  label: context.l10n.t('profile_section_addresses'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddressesScreen()),
                  ),
                ),
                ProfileSectionItem(
                  icon: Icons.credit_card_outlined,
                  label: context.l10n.t('profile_section_payment'),
                  onTap: () {}, // TODO: экран способов оплаты
                ),
                ProfileSectionItem(
                  icon: Icons.history_rounded,
                  label: context.l10n.t('profile_section_history'),
                  onTap: () {}, // TODO: история поездок
                ),
              ]),
              const SizedBox(height: 16),
              const PartnerPromoCard(),
              const SizedBox(height: 16),
              ProfileSectionGroup(items: [
                ProfileSectionItem(
                  icon: Icons.settings_outlined,
                  label: context.l10n.t('profile_section_settings'),
                  onTap: () {}, // TODO: настройки
                ),
                ProfileSectionItem(
                  icon: Icons.support_agent_rounded,
                  label: context.l10n.t('profile_section_support'),
                  onTap: () {}, // TODO: поддержка
                ),
                ProfileSectionItem(
                  icon: Icons.logout_rounded,
                  label: context.l10n.t('profile_logout'),
                  onTap: _logout,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}