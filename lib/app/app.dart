import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/locale_controller.dart';
import 'package:vental_go/features/main_hub/presentation/screens/main_hub_screen.dart';

class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VenTal Go',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const MainHubScreen(),
      ),
    );
  }
}