import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart' show themeNotifier;
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'savings_goals_screen.dart';
import 'pin_screen.dart';

class ProfileTab extends StatefulWidget {
  final void Function(int index)? onTabChange;

  const ProfileTab({super.key, this.onTabChange});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoading = false;
  bool _pinEnabled = false;
  bool _isDarkMode = false;
  double _alerteSolde = 100.0;
  double _budgetMensuel = 0.0;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final pinEnabled = await PreferencesService.instance.isPinEnabled();
    final isDark = themeNotifier.value == ThemeMode.dark;
    final userId = AuthService.utilisateurConnecte!.id!.toString();
    final alerte = await PreferencesService.instance.getAlerteSolde(userId);
    final budget = await PreferencesService.instance.getBudgetMensuel(userId);
    if (!mounted) return;
    setState(() {
      _pinEnabled = pinEnabled;
      _isDarkMode = isDark;
      _alerteSolde = alerte;
      _budgetMensuel = budget;
    });
  }

  // ─── Dark mode ────────────────────────────────────────────────────────────

  Future<void> _toggleDarkMode(bool value) async {
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    await PreferencesService.instance.setDarkMode(value);
    setState(() => _isDarkMode = value);
  }

  // ─── PIN ──────────────────────────────────────────────────────────────────

  Future<void> _configurerPin() async {
    if (_pinEnabled) {
      // Désactiver le PIN
      final confirme = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Désactiver le code PIN'),
          content: const Text('Voulez-vous supprimer le verrouillage par code PIN ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Désactiver', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirme != true) return;
      await PreferencesService.instance.disablePin();
      setState(() => _pinEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code PIN désactivé'), backgroundColor: Colors.orange),
        );
      }
    } else {
      // Activer le PIN
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const PinScreen(mode: PinMode.setup),
        ),
      );
      if (result == true) {
        setState(() => _pinEnabled = true);
      }
    }
  }

  Future<void> _changerPin() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const PinScreen(mode: PinMode.change),
      ),
    );
  }

  // ─── Nom ──────────────────────────────────────────────────────────────────

  Future<void> _modifierNom() async {
    final controller = TextEditingController(
      text: AuthService.utilisateurConnecte!.nom,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nom complet',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Sauvegarder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    if (result == AuthService.utilisateurConnecte!.nom) return;

    setState(() => _isLoading = true);
    await AuthService().mettreAJourProfil(nom: result);
    if (mounted) setState(() => _isLoading = false);
  }

  // ─── Mot de passe ─────────────────────────────────────────────────────────

  Future<void> _changerMotDePasse() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool showCurrent = false;
    bool showNew = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: !showCurrent,
                decoration: InputDecoration(
                  labelText: 'Mot de passe actuel',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: Icon(showCurrent ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => showCurrent = !showCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: !showNew,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  helperText: 'Minimum 6 caractères',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: Icon(showNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => showNew = !showNew),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: !showNew,
                decoration: InputDecoration(
                  labelText: 'Confirmer le nouveau mot de passe',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    if (!AuthService().verifierMotDePasse(currentCtrl.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe actuel incorrect'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (newCtrl.text.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le nouveau mot de passe doit contenir au moins 6 caractères'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (newCtrl.text != confirmCtrl.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    await AuthService().mettreAJourProfil(motDePasse: newCtrl.text);
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe modifié avec succès'), backgroundColor: Colors.green),
      );
    }
  }

  // ─── Alerte solde bas ─────────────────────────────────────────────────────

  Future<void> _configurerAlerte() async {
    final ctrl = TextEditingController(
      text: _alerteSolde.toStringAsFixed(0),
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alerte solde bas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recevez une alerte sur l\'accueil quand votre solde est inférieur à ce seuil.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Seuil d\'alerte',
                suffixText: '€',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Sauvegarder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != true) return;
    final val = double.tryParse(ctrl.text.trim());
    if (val != null && val >= 0) {
      await PreferencesService.instance.setAlerteSolde(AuthService.utilisateurConnecte!.id!.toString(), val);
      setState(() => _alerteSolde = val);
    }
  }

  // ─── Budget mensuel ────────────────────────────────────────────────────────

  Future<void> _configurerBudget() async {
    final ctrl = TextEditingController(
      text: _budgetMensuel > 0 ? _budgetMensuel.toStringAsFixed(0) : '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Budget mensuel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Définissez votre limite mensuelle de dépenses (visible dans Statistiques).',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Budget mensuel',
                suffixText: '€',
                hintText: 'Ex: 500',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          if (_budgetMensuel > 0)
            TextButton(
              onPressed: () async {
                await PreferencesService.instance.setBudgetMensuel(AuthService.utilisateurConnecte!.id!.toString(), 0);
                setState(() => _budgetMensuel = 0);
                if (ctx.mounted) Navigator.pop(ctx, false);
              },
              child: const Text('Désactiver', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Sauvegarder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != true) return;
    final val = double.tryParse(ctrl.text.trim());
    if (val != null && val > 0) {
      await PreferencesService.instance.setBudgetMensuel(AuthService.utilisateurConnecte!.id!.toString(), val);
      setState(() => _budgetMensuel = val);
    }
  }

  // ─── Déconnexion ──────────────────────────────────────────────────────────

  Future<void> _deconnecter() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirme != true) return;
    await AuthService().deconnecter();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.utilisateurConnecte!;
    final initiales = user.nom
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    final dateInscription = DateTime.tryParse(user.creeLe);
    const mois = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    final dateStr = dateInscription != null
        ? '${dateInscription.day} ${mois[dateInscription.month]} ${dateInscription.year}'
        : '';

    // Numéro de compte virtuel
    final userId = user.id ?? 0;
    final numBase = userId.toString().padLeft(8, '0');
    final numeroCompte = 'FR76 3000 6000 $numBase ${(userId * 17 % 97).toString().padLeft(2, '0')}';

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar & nom
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 44,
                            child: Text(
                              initiales,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _modifierNom,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.nom,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(user.email, style: const TextStyle(color: Colors.black54)),
                      if (dateStr.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Membre depuis le $dateStr',
                          style: const TextStyle(color: Colors.black38, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Solde + numéro compte
                Card(
                  color: AppColors.primaryLight,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              'Solde : ${user.soldeActuel.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          numeroCompte,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: Colors.black45,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Objectifs d'épargne
                _buildSectionTitle('Épargne'),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Text('🎯', style: TextStyle(fontSize: 24)),
                    title: const Text('Objectifs d\'épargne'),
                    subtitle: const Text('Suivre mes objectifs financiers'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Apparence
                _buildSectionTitle('Apparence'),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: SwitchListTile(
                    secondary: Icon(
                      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                    title: const Text('Mode sombre'),
                    subtitle: Text(_isDarkMode ? 'Thème sombre activé' : 'Thème clair activé'),
                    value: _isDarkMode,
                    activeColor: AppColors.primary,
                    onChanged: _toggleDarkMode,
                  ),
                ),

                const SizedBox(height: 16),

                // Sécurité
                _buildSectionTitle('Sécurité'),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline, color: AppColors.primary),
                        title: const Text('Modifier le nom'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _modifierNom,
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                        title: const Text('Changer le mot de passe'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _changerMotDePasse,
                      ),
                      const Divider(height: 1, indent: 56),
                      SwitchListTile(
                        secondary: const Icon(Icons.pin_outlined, color: AppColors.primary),
                        title: const Text('Code PIN'),
                        subtitle: Text(_pinEnabled ? 'Verrouillage activé' : 'Désactivé'),
                        value: _pinEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (_) => _configurerPin(),
                      ),
                      if (_pinEnabled) ...[
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                          title: const Text('Modifier le code PIN'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _changerPin,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Finances
                _buildSectionTitle('Finances'),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined,
                            color: AppColors.primary),
                        title: const Text('Alerte solde bas'),
                        subtitle: Text(
                          'Seuil : ${_alerteSolde.toStringAsFixed(0)} €',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _configurerAlerte,
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet_outlined,
                            color: AppColors.primary),
                        title: const Text('Budget mensuel'),
                        subtitle: Text(
                          _budgetMensuel > 0
                              ? '${_budgetMensuel.toStringAsFixed(0)} €/mois'
                              : 'Non défini',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _configurerBudget,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Infos
                _buildSectionTitle('Informations'),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: Colors.grey),
                        title: const Text('Version'),
                        trailing: const Text('2.0.0', style: TextStyle(color: Colors.black45)),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.shield_outlined, color: Colors.grey),
                        title: const Text('Données stockées localement'),
                        subtitle: const Text('Aucune donnée envoyée sur un serveur'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: _deconnecter,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.black45,
        letterSpacing: 1,
      ),
    );
  }
}
