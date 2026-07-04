import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../features/main_hub/presentation/screens/main_hub_screen.dart';

class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SuperApp',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MainHubScreen(),
    );
  }
}