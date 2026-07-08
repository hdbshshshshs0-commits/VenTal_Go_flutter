import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/locale_controller.dart';
import 'package:vental_go/core/city/city_controller.dart';
import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';
import 'role_router.dart';

class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CityController()..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VenTal Go',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const RoleRouter(),
      ),
    );
  }
}