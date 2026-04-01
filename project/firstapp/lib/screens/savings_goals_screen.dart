import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/goal_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';

/// Écran de gestion des objectifs d'épargne.
class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  List<GoalModel> _goals = [];
  bool _isLoading = true;

  static const _emojis = ['🎯', '🏠', '🚗', '✈️', '🎓', '💻', '📱', '🏖️', '💍', '🛍️'];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final user = AuthService.utilisateurConnecte!;
    final goals = await DatabaseService.instance.getObjectifs(user.id!);
    if (!mounted) return;
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  Future<void> _ajouterObjectif() async {
    final nomCtrl = TextEditingController();
    final montantCtrl = TextEditingController();
    String selectedEmoji = '🎯';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nouvel objectif'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sélecteur emoji
                Wrap(
                  spacing: 8,
                  children: _emojis.map((e) {
                    final isSelected = e == selectedEmoji;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedEmoji = e),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nomCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Nom de l\'objectif',
                    hintText: 'Ex: Voyage au Japon',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montantCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Montant cible',
                    suffixText: '€',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Créer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;
    final nom = nomCtrl.text.trim();
    final montant = double.tryParse(montantCtrl.text.trim());
    if (nom.isEmpty || montant == null || montant <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nom et montant valides requis'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final user = AuthService.utilisateurConnecte!;
    final goal = GoalModel(
      utilisateurId: user.id!,
      nom: nom,
      emoji: selectedEmoji,
      montantCible: montant,
      dateCreation: DateTime.now().toIso8601String(),
    );
    await DatabaseService.instance.creerObjectif(goal);
    await _charger();
  }

  Future<void> _ajouterMontant(GoalModel goal) async {
    final ctrl = TextEditingController();
    final user = AuthService.utilisateurConnecte!;
    final reste = goal.montantCible - goal.montantActuel;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Alimenter « ${goal.nom} »'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reste à atteindre : ${reste.toStringAsFixed(2)} €',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              'Solde disponible : ${user.soldeActuel.toStringAsFixed(2)} €',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Montant à ajouter',
                suffixText: '€',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              autofocus: true,
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
            child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != true) return;
    final montant = double.tryParse(ctrl.text.trim());
    if (montant == null || montant <= 0) return;

    // Vérifier que le solde est suffisant
    final userFrais = AuthService.utilisateurConnecte!;
    if (montant > userFrais.soldeActuel) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solde insuffisant pour alimenter cet objectif'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Mettre à jour l'objectif
    final nouveau = (goal.montantActuel + montant).clamp(0.0, goal.montantCible);
    final montantReel = nouveau - goal.montantActuel; // montant réellement prélevé (peut être < montant si plafond)
    await DatabaseService.instance.mettreAJourObjectif(goal.id!, nouveau);

    // Déduire du solde bancaire
    final nouveauSolde = userFrais.soldeActuel - montantReel;
    await DatabaseService.instance.mettreAJourSolde(userFrais.id!, nouveauSolde);
    AuthService.utilisateurConnecte!.soldeActuel = nouveauSolde;

    await _charger();

    if (nouveau >= goal.montantCible && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('🎉 Objectif atteint !'),
          content: Text('Félicitations ! Tu as atteint ton objectif « ${goal.nom} » !\n\n${montantReel.toStringAsFixed(2)} € ont été prélevés de ton compte.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Super !', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('- ${montantReel.toStringAsFixed(2)} € prélevés · Nouveau solde : ${nouveauSolde.toStringAsFixed(2)} €'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _supprimerObjectif(GoalModel goal) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'objectif'),
        content: Text(
          goal.montantActuel > 0
              ? 'Supprimer « ${goal.nom} » ?\n\n${goal.montantActuel.toStringAsFixed(2)} € épargnés seront remboursés sur votre compte.'
              : 'Supprimer « ${goal.nom} » ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    // Rembourser le montant épargné au solde si l'objectif n'est pas encore atteint
    if (goal.montantActuel > 0) {
      final user = AuthService.utilisateurConnecte!;
      final soldeRembourse = user.soldeActuel + goal.montantActuel;
      await DatabaseService.instance.mettreAJourSolde(user.id!, soldeRembourse);
      AuthService.utilisateurConnecte!.soldeActuel = soldeRembourse;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+ ${goal.montantActuel.toStringAsFixed(2)} € remboursés sur votre compte'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    await DatabaseService.instance.supprimerObjectif(goal.id!);
    await _charger();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectifs d\'épargne'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterObjectif,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvel objectif'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _charger,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _goals.length,
                    itemBuilder: (_, i) => _buildGoalCard(_goals[i]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Aucun objectif d\'épargne',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez un objectif pour suivre votre progression vers vos rêves !',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _ajouterObjectif,
              icon: const Icon(Icons.add),
              label: const Text('Créer mon premier objectif'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final pct = (goal.progression * 100).toStringAsFixed(0);
    final reste = goal.montantCible - goal.montantActuel;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: InkWell(
        onTap: goal.estAtteint ? null : () => _ajouterMontant(goal),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(goal.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.nom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          goal.estAtteint
                              ? '🎉 Objectif atteint !'
                              : 'Reste : ${reste.toStringAsFixed(2)} €',
                          style: TextStyle(
                            color: goal.estAtteint ? Colors.green : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _supprimerObjectif(goal),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.montantActuel.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: goal.estAtteint ? Colors.green : AppColors.primary,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: goal.estAtteint ? Colors.green : AppColors.primary,
                    ),
                  ),
                  Text(
                    '${goal.montantCible.toStringAsFixed(2)} €',
                    style: const TextStyle(color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progression,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.estAtteint ? Colors.green : AppColors.primary,
                  ),
                  minHeight: 10,
                ),
              ),
              if (!goal.estAtteint) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _ajouterMontant(goal),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Ajouter de l\'argent'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
