import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user_model.dart';
import '../models/user_role.dart';

/// Auth service. Currently mock-based (no real backend required).
/// When Go backend is wired in, replace login/register/google with real HTTP calls.
/// The method signatures are stable — screens won't need touching.
class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'auth_session_user';

  // ── Google sign-in ───────────────────────────────────────────────────────
  static final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // ── Mock accounts ────────────────────────────────────────────────────────
  static final List<({String phone, String password, AuthUserModel user})>
      _testAccounts = [
    (
      phone: '+77001234501',
      password: 'client123',
      user: const AuthUserModel(
          phone: '+77001234501',
          name: 'Тестовый клиент',
          role: UserRole.client),
    ),
    (
      phone: '+77001234502',
      password: 'courier123',
      user: const AuthUserModel(
          phone: '+77001234502',
          name: 'Тестовый курьер',
          role: UserRole.courier),
    ),
    (
      phone: '+77001234503',
      password: 'driver123',
      user: const AuthUserModel(
          phone: '+77001234503',
          name: 'Тестовый водитель',
          role: UserRole.driver),
    ),
    (
      phone: '+77001234504',
      password: 'restaurant123',
      user: const AuthUserModel(
          phone: '+77001234504',
          name: 'Тестовый ресторан',
          role: UserRole.restaurant),
    ),
    (
      phone: '+77001234505',
      password: 'admin123',
      user: const AuthUserModel(
          phone: '+77001234505',
          name: 'Тестовый админ',
          role: UserRole.admin),
    ),
  ];

  // ── Login ────────────────────────────────────────────────────────────────
  static Future<AuthUserModel?> login(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (final account in _testAccounts) {
      if (account.phone == phone && account.password == password) {
        await _saveSession(account.user);
        return account.user;
      }
    }
    return null;
  }

  // ── Register ─────────────────────────────────────────────────────────────
  static Future<AuthUserModel?> register(
      String name, String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In production: POST /api/v1/auth/register { name, phone, password }
    // For now: create local mock session
    final user = AuthUserModel(
      phone: phone,
      name: name.trim().isEmpty ? phone : name.trim(),
      role: UserRole.client,
    );
    await _saveSession(user);
    return user;
  }

  // ── Google sign-in ───────────────────────────────────────────────────────
  static Future<AuthUserModel?> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // user cancelled

      final user = AuthUserModel(
        phone: '', // Google users may not have phone
        name: account.displayName ?? account.email,
        role: UserRole.client,
        email: account.email,
      );
      // In production: exchange account.authentication.idToken for a JWT
      // via POST /api/v1/auth/google { id_token }
      await _saveSession(user);
      return user;
    } catch (_) {
      return null;
    }
  }

  // ── Update avatar ────────────────────────────────────────────────────────
  static Future<AuthUserModel?> updateAvatar(
      AuthUserModel current, String avatarPath) async {
    final updated = current.copyWith(avatarPath: avatarPath);
    await _saveSession(updated);
    return updated;
  }

  // ── Session ──────────────────────────────────────────────────────────────
  static Future<AuthUserModel?> restoreSession() async {
    try {
      final raw = await _storage.read(key: _sessionKey);
      if (raw == null) return null;
      return AuthUserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _storage.delete(key: _sessionKey);
      return null;
    }
  }

  static Future<void> _saveSession(AuthUserModel user) async {
    await _storage.write(key: _sessionKey, value: jsonEncode(user.toJson()));
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _storage.delete(key: _sessionKey);
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
