import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobileapp_prjtst/screens/app_shell.dart';
import 'package:mobileapp_prjtst/screens/login_screen.dart';
import 'package:mobileapp_prjtst/screens/verify_email_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    // Safety timeout: never stay stuck on splash.
    final timeout = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    });

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      final auth = Supabase.instance.client.auth;
      final session = auth.currentSession;

      if (!mounted) return;
      timeout.cancel();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) {
            if (session == null) return const LoginScreen();

            final user = auth.currentUser;

            // If email confirmation is enabled, gate entry until confirmed.
            final confirmed = (() {
              try {
                final v = (user as dynamic).emailConfirmedAt;
                return v != null && v.toString().isNotEmpty;
              } catch (_) {
                // If the field doesn't exist (SDK changes), don't block.
                return true;
              }
            })();

            if (!confirmed && user?.email != null) {
              return VerifyEmailScreen(email: user!.email!);
            }

            // ✅ IMPORTANT: go to the tab shell so "Profil" exists
            return const AppShell();
          },
        ),
      );
    } catch (_) {
      if (!mounted) return;
      timeout.cancel();

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/branding/uapay_logo.png',
                  height: 90,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 14),
                const Text(
                  'UAPay',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Chargement…',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
