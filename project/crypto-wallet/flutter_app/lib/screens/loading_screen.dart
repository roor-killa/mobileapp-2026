import 'package:flutter/material.dart';
import '../app_theme.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 80, color: AppTheme.primary),
            SizedBox(height: 24),
            Text('NodEX', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            SizedBox(height: 8),
            Text('Chargement...', style: TextStyle(color: AppTheme.textSecondary)),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
