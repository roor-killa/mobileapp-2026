import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MotdepasseoublieWidget extends StatefulWidget {
  const MotdepasseoublieWidget({super.key});

  static String routeName = 'Motdepasseoublie';
  static String routePath = '/motdepasseoublie';

  @override
  State<MotdepasseoublieWidget> createState() => _MotdepasseoublieWidgetState();
}

class _MotdepasseoublieWidgetState extends State<MotdepasseoublieWidget> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _reinitialiserMotDePasse() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail requis !')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail de réinitialisation envoyé !')));
      Navigator.pushNamedAndRemoveUntil(context, '/page-de-connexion', (route) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : ${e.message}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus(); FocusManager.instance.primaryFocus?.unfocus(); },
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Mot de passe oublié', style: TextStyle(color: cs.onSurface, fontSize: 22, fontWeight: FontWeight.w600)),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrez votre adresse e-mail pour réinitialiser votre mot de passe.',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 16),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Adresse e-mail',
                            labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                            filled: true,
                            fillColor: cs.surface,
                            contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: cs.outline, width: 1), borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: cs.primary, width: 1), borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _reinitialiserMotDePasse,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cs.primary,
                              side: BorderSide(color: cs.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: _isLoading
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary))
                                : const Text('Réinitialiser le mot de passe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Vous recevrez un vrai e-mail avec un lien pour réinitialiser votre mot de passe.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 12),
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
