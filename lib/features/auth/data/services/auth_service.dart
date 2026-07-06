import '../models/auth_user_model.dart';
import '../models/user_role.dart';

/// MOCK-авторизация. Реального бэкенда ещё нет — вход проверяется по
/// зашитому списку тестовых пар (телефон, пароль) ниже. Когда появится
/// Go-бэкенд, метод login() меняется на реальный HTTP POST /auth/login,
/// сигнатура (принимает phone+password, возвращает AuthUserModel?) не
/// меняется — экраны трогать не придётся.
class AuthService {
  static final List<({String phone, String password, AuthUserModel user})> _testAccounts = [
    (
      phone: '+77001234501',
      password: 'client123',
      user: const AuthUserModel(phone: '+77001234501', name: 'Тестовый клиент', role: UserRole.client),
    ),
    (
      phone: '+77001234502',
      password: 'courier123',
      user: const AuthUserModel(phone: '+77001234502', name: 'Тестовый курьер', role: UserRole.courier),
    ),
    (
      phone: '+77001234503',
      password: 'driver123',
      user: const AuthUserModel(phone: '+77001234503', name: 'Тестовый водитель', role: UserRole.driver),
    ),
    (
      phone: '+77001234504',
      password: 'restaurant123',
      user: const AuthUserModel(phone: '+77001234504', name: 'Тестовый ресторан', role: UserRole.restaurant),
    ),
    (
      phone: '+77001234505',
      password: 'admin123',
      user: const AuthUserModel(phone: '+77001234505', name: 'Тестовый админ', role: UserRole.admin),
    ),
  ];

  static Future<AuthUserModel?> login(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // имитация сетевого запроса
    for (final account in _testAccounts) {
      if (account.phone == phone && account.password == password) {
        return account.user;
      }
    }
    return null;
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // TODO: очистка токена/сессии, когда появится реальный бэкенд
  }
}
