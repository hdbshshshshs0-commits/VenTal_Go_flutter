import 'package:flutter/foundation.dart';

import '../../data/models/auth_user_model.dart';
import '../../data/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthUserModel? currentUser;
  bool isLoading = false;
  bool isInitializing = true;
  String? errorMessage;

  AuthController() {
    _restoreSession();
  }

  bool get isLoggedIn => currentUser != null;

  Future<void> _restoreSession() async {
    currentUser = await AuthService.restoreSession();
    isInitializing = false;
    notifyListeners();
  }

  // ── Login ────────────────────────────────────────────────────────────────
  Future<bool> login(String phone, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = await AuthService.login(phone, password);
    isLoading = false;
    if (user == null) {
      errorMessage = 'auth_invalid_credentials';
      notifyListeners();
      return false;
    }
    currentUser = user;
    notifyListeners();
    return true;
  }

  // ── Register ─────────────────────────────────────────────────────────────
  Future<bool> register(String name, String phone, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = await AuthService.register(name, phone, password);
    isLoading = false;
    if (user == null) {
      errorMessage = 'auth_register_error';
      notifyListeners();
      return false;
    }
    currentUser = user;
    notifyListeners();
    return true;
  }

  // ── Google ───────────────────────────────────────────────────────────────
  Future<bool> loginWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = await AuthService.loginWithGoogle();
    isLoading = false;
    if (user == null) {
      errorMessage = null; // user cancelled — not an error
      notifyListeners();
      return false;
    }
    currentUser = user;
    notifyListeners();
    return true;
  }

  // ── Update avatar ────────────────────────────────────────────────────────
  Future<void> updateAvatar(String avatarPath) async {
    if (currentUser == null) return;
    final updated = await AuthService.updateAvatar(currentUser!, avatarPath);
    if (updated != null) {
      currentUser = updated;
      notifyListeners();
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await AuthService.logout();
    currentUser = null;
    notifyListeners();
  }
}
