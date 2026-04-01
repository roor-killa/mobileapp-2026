import 'package:flutter/material.dart';
import 'package:fatoubank/screens/login/login_screen.dart';
import 'package:fatoubank/utils/colors.dart';

class EcobankApp extends StatelessWidget {
  const EcobankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecobank',
      theme: ThemeData.light().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appBarBackground,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}