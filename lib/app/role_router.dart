import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';
import 'package:vental_go/features/auth/data/models/user_role.dart';
import 'package:vental_go/features/auth/presentation/screens/login_screen.dart';
import 'package:vental_go/features/main_hub/presentation/screens/main_hub_screen.dart';
import 'package:vental_go/features/courier_panel/presentation/screens/courier_home_screen.dart';
import 'package:vental_go/features/driver_panel/presentation/screens/driver_home_screen.dart';
import 'package:vental_go/features/restaurant_panel/presentation/screens/restaurant_orders_kanban_screen.dart';

/// Направляет пользователя на нужный интерфейс по роли после логина.
/// Пока auth.isInitializing == true — идёт проверка сохранённой сессии
/// (secure storage); показываем лоадер вместо мгновенного перехода на
/// LoginScreen, чтобы не было "мигания" логина при каждом холодном старте.
/// Админ временно ведёт на главный экран клиента — отдельный
/// админ-интерфейс не запрошен, TODO на будущее.
class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = auth.currentUser;
    if (user == null) return const LoginScreen();

    switch (user.role) {
      case UserRole.client:
      case UserRole.admin:
        return const MainHubScreen();
      case UserRole.courier:
        return const CourierHomeScreen();
      case UserRole.driver:
        return const DriverHomeScreen();
      case UserRole.restaurant:
        return const RestaurantOrdersKanbanScreen();
    }
  }
}