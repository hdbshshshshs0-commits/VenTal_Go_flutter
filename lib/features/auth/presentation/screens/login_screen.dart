import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/widgets/phone_input_field.dart';
import 'package:vental_go/features/location/presentation/state/location_controller.dart';
import 'package:vental_go/features/location/presentation/sheets/country_city_picker_sheet.dart';
import 'package:vental_go/features/location/presentation/sheets/address_input_sheet.dart';
import '../state/auth_controller.dart';
import 'package:vental_go/app/role_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Login
  String _loginPhone = '';
  final _loginPasswordCtrl = TextEditingController();

  // Register
  final _nameCtrl = TextEditingController();
  String _regPhone = '';
  final _regPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPasswordCtrl.dispose();
    _nameCtrl.dispose();
    _regPasswordCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  Future<void> _goToMain() async {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleRouter()),
      (route) => false,
    );
  }

  /// After registration: show location setup, then go to main.
  Future<void> _goToMainWithLocationSetup() async {
    if (!mounted) return;
    final loc = context.read<LocationController>();
    if (!loc.citySetupDone) {
      final result = await showCountryCityPicker(context);
      if (result != null && mounted) {
        await loc.setCity(result.country, result.city);
        if (mounted) await showAddressInputSheet(context);
      }
    }
    _goToMain();
  }

  // ── Login ────────────────────────────────────────────────────────────────

  Future<void> _submitLogin(AuthController auth) async {
    final success = await auth.login(_loginPhone, _loginPasswordCtrl.text);
    if (success && mounted) _goToMain();
  }

  // ── Register ─────────────────────────────────────────────────────────────

  Future<void> _submitRegister(AuthController auth) async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError(context.l10n.t('auth_name_required'));
      return;
    }
    final success = await auth.register(
      _nameCtrl.text.trim(),
      _regPhone,
      _regPasswordCtrl.text,
    );
    if (success && mounted) _goToMainWithLocationSetup();
  }

  // ── Google ───────────────────────────────────────────────────────────────

  Future<void> _googleSignIn(AuthController auth) async {
    final success = await auth.loginWithGoogle();
    if (!mounted) return;
    if (success) {
      _goToMainWithLocationSetup();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Logo / header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/icons/vt_logo.png',
                    width: 72,
                    height: 72,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text('VT',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'VenTal',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Tab bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textHint,
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  indicator: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: context.l10n.t('auth_login_button')),
                    Tab(text: context.l10n.t('auth_register_title')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Tab content ──────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Login tab
                  _LoginTab(
                    auth: auth,
                    onPhoneChanged: (v) => _loginPhone = v,
                    passwordCtrl: _loginPasswordCtrl,
                    onSubmit: () => _submitLogin(auth),
                    onGoogle: () => _googleSignIn(auth),
                  ),
                  // Register tab
                  _RegisterTab(
                    auth: auth,
                    nameCtrl: _nameCtrl,
                    onPhoneChanged: (v) => _regPhone = v,
                    passwordCtrl: _regPasswordCtrl,
                    onSubmit: () => _submitRegister(auth),
                    onGoogle: () => _googleSignIn(auth),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Login Tab ────────────────────────────────────────────────────────────────

class _LoginTab extends StatelessWidget {
  final AuthController auth;
  final ValueChanged<String> onPhoneChanged;
  final TextEditingController passwordCtrl;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;

  const _LoginTab({
    required this.auth,
    required this.onPhoneChanged,
    required this.passwordCtrl,
    required this.onSubmit,
    required this.onGoogle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PhoneInputField(onChanged: onPhoneChanged),
          const SizedBox(height: 12),
          _PasswordField(controller: passwordCtrl),
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.t(auth.errorMessage!),
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          _PrimaryButton(
            label: context.l10n.t('auth_login_button'),
            isLoading: auth.isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12),
          _Divider(),
          const SizedBox(height: 12),
          _GoogleButton(onPressed: onGoogle, isLoading: auth.isLoading),
        ],
      ),
    );
  }
}

// ─── Register Tab ─────────────────────────────────────────────────────────────

class _RegisterTab extends StatelessWidget {
  final AuthController auth;
  final TextEditingController nameCtrl;
  final ValueChanged<String> onPhoneChanged;
  final TextEditingController passwordCtrl;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;

  const _RegisterTab({
    required this.auth,
    required this.nameCtrl,
    required this.onPhoneChanged,
    required this.passwordCtrl,
    required this.onSubmit,
    required this.onGoogle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name
          _TextField(
            controller: nameCtrl,
            hint: context.l10n.t('auth_name_hint'),
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          PhoneInputField(onChanged: onPhoneChanged),
          const SizedBox(height: 12),
          _PasswordField(controller: passwordCtrl),
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.t(auth.errorMessage!),
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          _PrimaryButton(
            label: context.l10n.t('auth_register_button'),
            isLoading: auth.isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12),
          _Divider(),
          const SizedBox(height: 12),
          _GoogleButton(onPressed: onGoogle, isLoading: auth.isLoading),
          const SizedBox(height: 8),
          const Text(
            'После регистрации вам предложат выбрать\nгород и адрес доставки.',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _TextField(
      {required this.controller, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  const _PasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: context.l10n.t('auth_password_hint'),
        prefixIcon:
            const Icon(Icons.lock_outline_rounded, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton(
      {required this.label, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: const TextStyle(
                    color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  const _GoogleButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.divider, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google 'G' logo
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Text('G',
                    style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w900,
                        fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.l10n.t('auth_google_button'),
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('или',
              style: TextStyle(fontSize: 13, color: AppColors.textHint)),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
