import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/session_store.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();

  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _loginEmail.dispose();
    _loginPass.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _doLogin() async {
    final email = _loginEmail.text.trim().toLowerCase();
    final pass = _loginPass.text;

    if (!email.contains("@")) return _snack("Email invalide.");
    if (pass.length < 6) return _snack("Mot de passe trop court.");

    setState(() => _busy = true);
    try {
      final token = await api.login(email, pass);
      await SessionStore.saveSession(token: token, email: email);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed("/app");
    } catch (e) {
      _snack("Connexion impossible: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doRegister() async {
    final email = _regEmail.text.trim().toLowerCase();
    final pass = _regPass.text;

    if (!email.contains("@")) return _snack("Email invalide.");
    if (pass.length < 6) return _snack("Mot de passe trop court (min 6).");

    setState(() => _busy = true);
    try {
      await api.register(email, pass);
      final token = await api.login(email, pass);
      await SessionStore.saveSession(token: token, email: email);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed("/app");
    } catch (e) {
      _snack("Inscription impossible: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF070B10),
      body: SafeArea(
        child: Stack(
          children: [
            // fond “futuriste” léger
            Positioned.fill(
              child: CustomPaint(painter: _GlowPainter(primary: cs.primary, secondary: cs.secondary)),
            ),

            ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [cs.primary.withOpacity(0.95), cs.secondary.withOpacity(0.9)],
                        ),
                        boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.35), blurRadius: 18)],
                      ),
                      child: Icon(Icons.account_balance_wallet_rounded, color: cs.onPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("NeoBank", style: TextStyle(color: cs.onSurface, fontSize: 22, fontWeight: FontWeight.w900)),
                          Text("Compte • crypto • investissements",
                              style: TextStyle(color: cs.onSurface.withOpacity(0.65), fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 18),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: cs.surface.withOpacity(0.55),
                    border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                  ),
                  child: TabBar(
                    controller: _tab,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: cs.primary.withOpacity(0.18),
                    ),
                    tabs: const [
                      Tab(text: "Connexion"),
                      Tab(text: "Inscription"),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 430,
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _AuthCard(
                        title: "Connexion",
                        subtitle: "Accède à ton compte en toute sécurité",
                        primary: cs.primary,
                        child: Column(
                          children: [
                            _Field(controller: _loginEmail, label: "Email", hint: "a@test.com", icon: Icons.alternate_email_rounded),
                            const SizedBox(height: 12),
                            _Field(controller: _loginPass, label: "Mot de passe", hint: "••••••", icon: Icons.lock_rounded, obscure: true),
                            const SizedBox(height: 16),
                            _PrimaryButton(
                              label: "Se connecter",
                              busy: _busy,
                              onTap: _doLogin,
                            ),
                          ],
                        ),
                      ),
                      _AuthCard(
                        title: "Inscription",
                        subtitle: "Crée ton compte (démo)",
                        primary: cs.secondary,
                        child: Column(
                          children: [
                            _Field(controller: _regEmail, label: "Email", hint: "b@test.com", icon: Icons.alternate_email_rounded),
                            const SizedBox(height: 12),
                            _Field(controller: _regPass, label: "Mot de passe", hint: "min 6 caractères", icon: Icons.lock_rounded, obscure: true),
                            const SizedBox(height: 16),
                            _PrimaryButton(
                              label: "Créer le compte",
                              busy: _busy,
                              onTap: _doRegister,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  "Astuce: pour Android plus tard, l’URL ne sera pas 127.0.0.1 (on fera 10.0.2.2).",
                  style: TextStyle(color: cs.onSurface.withOpacity(0.55), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color primary;
  final Widget child;

  const _AuthCard({required this.title, required this.subtitle, required this.primary, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.surface.withOpacity(0.65), cs.surface.withOpacity(0.35)],
        ),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: cs.onSurface.withOpacity(0.65), fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: cs.surface.withOpacity(0.55),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.onSurface.withOpacity(0.08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.onSurface.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.primary.withOpacity(0.75), width: 1.6)),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: busy ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: busy
              ? const SizedBox(key: ValueKey("l"), width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
              : Text(key: const ValueKey("t"), label, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  _GlowPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;

    // gros glow haut gauche
    p.shader = RadialGradient(
      colors: [primary.withOpacity(0.22), Colors.transparent],
    ).createShader(Rect.fromCircle(center: const Offset(0, 0), radius: size.shortestSide * 0.8));
    canvas.drawCircle(const Offset(0, 0), size.shortestSide * 0.8, p);

    // glow bas droite
    p.shader = RadialGradient(
      colors: [secondary.withOpacity(0.16), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: size.shortestSide * 0.9));
    canvas.drawCircle(Offset(size.width, size.height), size.shortestSide * 0.9, p);

    // lignes diagonales discrètes
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    for (int i = -3; i < 12; i++) {
      final y = i * 80.0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width * 0.25), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}