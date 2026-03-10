import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Étape 1 : vérification email  |  Étape 2 : nouveau mot de passe
  int _etape = 1;

  final _emailController = TextEditingController();
  final _newMdpController = TextEditingController();
  final _confirmMdpController = TextEditingController();

  bool _isLoading = false;
  bool _newMdpVisible = false;
  String? _emailValide;
  int? _userIdValide;

  // ── Étape 1 : vérifier que l'email existe ──────────────────────────────────
  Future<void> _verifierEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _afficherErreur('Veuillez entrer votre adresse email');
      return;
    }

    setState(() => _isLoading = true);

    final user = await DatabaseService.instance.trouverParEmail(email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user == null) {
      _afficherErreur('Aucun compte associé à cet email');
      return;
    }

    setState(() {
      _emailValide = email;
      _userIdValide = user.id;
      _etape = 2;
    });
  }

  // ── Étape 2 : enregistrer le nouveau mot de passe ─────────────────────────
  Future<void> _reinitialiserMdp() async {
    final newMdp = _newMdpController.text;
    final confirmMdp = _confirmMdpController.text;

    if (newMdp.isEmpty || confirmMdp.isEmpty) {
      _afficherErreur('Veuillez remplir tous les champs');
      return;
    }

    if (newMdp.length < 6) {
      _afficherErreur('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    if (newMdp != confirmMdp) {
      _afficherErreur('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _isLoading = true);

    final hashedMdp = AuthService.hasherMotDePasse(newMdp);
    await DatabaseService.instance.mettreAJourUtilisateur(
      _userIdValide!,
      motDePasse: hashedMdp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mot de passe réinitialisé avec succès !'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.primaryLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.lock_reset, size: 72, color: AppColors.primary),
            const SizedBox(height: 24),
            _buildEtapeIndicateur(),
            const SizedBox(height: 32),
            if (_etape == 1) _buildEtape1() else _buildEtape2(),
          ],
        ),
      ),
    );
  }

  Widget _buildEtapeIndicateur() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPoint(1, 'Email'),
        Container(
          width: 40,
          height: 2,
          color: _etape >= 2 ? AppColors.primary : Colors.grey.shade300,
        ),
        _buildPoint(2, 'Nouveau mot de passe'),
      ],
    );
  }

  Widget _buildPoint(int numero, String label) {
    final actif = _etape >= numero;
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: actif ? AppColors.primary : Colors.grey.shade300,
          child: Text(
            '$numero',
            style: TextStyle(
              color: actif ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: actif ? AppColors.primary : Colors.grey,
            fontWeight: actif ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildEtape1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Entrez l\'adresse email associée à votre compte.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Adresse email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          onSubmitted: (_) => _verifierEmail(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifierEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Vérifier l\'email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildEtape2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Confirmation de l'email trouvé
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Compte trouvé : $_emailValide',
                  style: const TextStyle(color: Colors.green, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Choisissez un nouveau mot de passe.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _newMdpController,
          obscureText: !_newMdpVisible,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nouveau mot de passe',
            helperText: 'Minimum 6 caractères',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_newMdpVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _newMdpVisible = !_newMdpVisible),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmMdpController,
          obscureText: !_newMdpVisible,
          decoration: InputDecoration(
            labelText: 'Confirmer le mot de passe',
            prefixIcon: const Icon(Icons.lock_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          onSubmitted: (_) => _reinitialiserMdp(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _reinitialiserMdp,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Réinitialiser le mot de passe',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() {
            _etape = 1;
            _emailValide = null;
            _userIdValide = null;
          }),
          child: const Text('← Retour', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newMdpController.dispose();
    _confirmMdpController.dispose();
    super.dispose();
  }
}
