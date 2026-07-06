import 'package:flutter/foundation.dart';

import '../../data/models/auth_user_model.dart';
import '../../data/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthUserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => currentUser != null;

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

  Future<void> logout() async {
    await AuthService.logout();
    currentUser = null;
    notifyListeners();
  }
}
