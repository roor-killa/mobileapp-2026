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

  final _regFirst = TextEditingController();
  final _regLast = TextEditingController();
  final _regPhone = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();
  final _regPass2 = TextEditingController();

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
    _regFirst.dispose();
    _regLast.dispose();
    _regPhone.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    _regPass2.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  bool _strongPw(String p) =>
      p.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(p) &&
      RegExp(r'[a-z]').hasMatch(p) &&
      RegExp(r'\d').hasMatch(p);

  Future<void> _doLogin() async {
    final email = _loginEmail.text.trim().toLowerCase();
    final pass = _loginPass.text;

    if (!email.contains("@")) return _snack("Email invalide.");
    if (pass.length < 6) return _snack("Mot de passe trop court.");

    setState(() => _busy = true);
    try {
      final data = await api.login(email, pass);
      final token = (data["access_token"] ?? "").toString();
      final refresh = (data["refresh_token"] ?? "").toString();
      await SessionStore.saveToken(token);
      if (refresh.isNotEmpty) await SessionStore.saveRefreshToken(refresh);
      api.setToken(token);
      api.setRefreshToken(refresh);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed("/app");
    } catch (e) {
      _snack("Connexion impossible: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doRegister() async {
    final first = _regFirst.text.trim();
    final last = _regLast.text.trim();
    final phone = _regPhone.text.trim();
    final email = _regEmail.text.trim().toLowerCase();
    final pass = _regPass.text;
    final pass2 = _regPass2.text;

    if (first.length < 2) return _snack("Prénom invalide.");
    if (last.length < 2) return _snack("Nom invalide.");
    if (phone.length < 8) return _snack("Téléphone invalide.");
    if (!email.contains("@")) return _snack("Email invalide.");
    if (!_strongPw(pass)) return _snack("Mot de passe faible (min 8 + maj + min + chiffre).");
    if (pass != pass2) return _snack("Les mots de passe ne correspondent pas.");

    setState(() => _busy = true);
    try {
      // IMPORTANT: ton Api doit avoir register(email, password, firstName, lastName, phone)
      await api.register(
        email: email,
        password: pass,
        firstName: first,
        lastName: last,
        phone: phone,
      );

      final data = await api.login(email, pass);
      final token = (data["access_token"] ?? "").toString();
      final refresh = (data["refresh_token"] ?? "").toString();
      await SessionStore.saveToken(token);
      if (refresh.isNotEmpty) await SessionStore.saveRefreshToken(refresh);
      api.setToken(token);
      api.setRefreshToken(refresh);
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                    boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.35), blurRadius: 18)],
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded, color: cs.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("NeoBank",
                          style: TextStyle(color: cs.onSurface, fontSize: 22, fontWeight: FontWeight.w900)),
                      Text("Compte • virement • marché",
                          style: TextStyle(color: cs.onSurface.withOpacity(0.65), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
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
              height: 560,
              child: TabBarView(
                controller: _tab,
                children: [
                  // =======================
                  // CONNEXION
                  // =======================
                  _AuthCard(
                    title: "Connexion",
                    child: Column(
                      children: [
                        _Field(
                          controller: _loginEmail,
                          label: "Email",
                          hint: "a@test.com",
                          icon: Icons.alternate_email_rounded,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _loginPass,
                          label: "Mot de passe",
                          hint: "••••••",
                          icon: Icons.lock_rounded,
                          obscure: true,
                        ),
                        const SizedBox(height: 16),
                        _PrimaryButton(label: "Se connecter", busy: _busy, onTap: _doLogin),

                        // ✅ BOUTON POUR ALLER À INSCRIPTION
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _busy ? null : () => _tab.animateTo(1),
                          child: Text(
                            "Créer un compte",
                            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =======================
                  // INSCRIPTION
                  // =======================
                  _AuthCard(
                    title: "Inscription",
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _Field(
                                controller: _regFirst,
                                label: "Prénom",
                                hint: "Noah",
                                icon: Icons.person_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Field(
                                controller: _regLast,
                                label: "Nom",
                                hint: "Tally",
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _regPhone,
                          label: "Téléphone",
                          hint: "+596 ...",
                          icon: Icons.phone_rounded,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _regEmail,
                          label: "Email",
                          hint: "b@test.com",
                          icon: Icons.alternate_email_rounded,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _regPass,
                          label: "Mot de passe",
                          hint: "min 8 + maj + min + chiffre",
                          icon: Icons.lock_rounded,
                          obscure: true,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _regPass2,
                          label: "Confirmer",
                          hint: "retape le mot de passe",
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                        ),
                        const SizedBox(height: 16),
                        _PrimaryButton(label: "Créer le compte", busy: _busy, onTap: _doRegister),

                        // ✅ BOUTON POUR REVENIR À CONNEXION
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _busy ? null : () => _tab.animateTo(0),
                          child: Text(
                            "J’ai déjà un compte",
                            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _AuthCard({required this.title, required this.child});

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
              ? const SizedBox(
                  key: ValueKey("l"),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : Text(
                  key: const ValueKey("t"),
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
        ),
      ),
    );
  }
}