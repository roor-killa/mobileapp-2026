import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/services/api_service.dart';

class QrReceiveScreen extends StatelessWidget {
  const QrReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pseudo = ApiService.currentUserPseudo ?? '@john_doe';
    final userId = ApiService.currentUserId ?? '1';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recevoir des BKN'), 
        centerTitle: true
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // QR Code
                Container(
                  width: 280,
                  height: 280,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10)
                      )
                    ],
                  ),
                  child: QrImageView(
                    data: 'bkn://payment/$userId',
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue, // Garder foregroundColor pour les modules
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Identifiant
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5)
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Votre identifiant BKN',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pseudo,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                          letterSpacing: -0.5
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryBlue,
                        size: 24
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Scannez ce code QR pour recevoir des BKN instantanément',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            height: 1.4
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Bouton Partager
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('📋 QR Code copié dans le presse-papiers'),
                        backgroundColor: AppTheme.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.share,
                    color: AppTheme.primaryBlue
                  ),
                  label: const Text(
                    'Partager mon QR code',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14
                    ),
                    side: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 1.5
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}