import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import '../services/bank_service.dart';

/// Page Sécurité et confidentialité (accessible depuis Profil).
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité et confidentialité'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space24, vertical: DesignSystem.space16),
        children: [
          _section(
            context,
            'Compte',
            [
              _tile(context, Icons.lock_rounded, 'Changer le mot de passe', 'Modifiez votre mot de passe régulièrement pour plus de sécurité.', () => _openChangePasswordDialog(context)),
              _tile(context, Icons.verified_user_rounded, 'Vérification d\'identité', 'Votre compte est vérifié.', null),
            ],
          ),
          const SizedBox(height: DesignSystem.space24),
          _section(
            context,
            'Confidentialité',
            [
              _tile(context, Icons.security_rounded, 'Données personnelles', 'Consultez et exportez vos données.', () => _showSnackBar(context, 'Demande d\'export envoyée. Vous recevrez un email avec le lien.')),
              _tile(context, Icons.history_rounded, 'Historique de connexion', 'Dernières connexions à votre compte.', () => _showSnackBar(context, 'Fonctionnalité à venir.')),
            ],
          ),
          const SizedBox(height: DesignSystem.space24),
          _section(
            context,
            'Sécurité',
            [
              _tile(context, Icons.fingerprint_rounded, 'Connexion biométrique', 'Déverrouillez l\'app avec votre empreinte ou Face ID.', () => _showSnackBar(context, 'Activez ou désactivez dans Profil > Préférences.')),
              _tile(context, Icons.notifications_rounded, 'Alertes de sécurité', 'Recevez une alerte en cas de connexion depuis un nouvel appareil.', () => _showSnackBar(context, 'Paramétrable depuis les notifications.')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: DesignSystem.gray400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignSystem.green500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                ),
                child: Icon(icon, size: 22, color: DesignSystem.green600),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, size: 22, color: DesignSystem.gray400),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _ChangePasswordDialog(),
    );
  }
}

/// Dialogue pour changer le mot de passe (mot de passe actuel + nouveau + confirmation).
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;

    final current = _currentController.text;
    final newPass = _newController.text;

    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      await BankService().changePassword(
        currentPassword: current,
        newPassword: newPass,
      );
      if (!mounted) return;
      nav.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Mot de passe modifié avec succès.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: DesignSystem.green500,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Changer le mot de passe'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: DesignSystem.red50,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                    border: Border.all(color: DesignSystem.red500.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: DesignSystem.red500, size: 22),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(fontSize: 13, color: DesignSystem.red500))),
                    ],
                  ),
                ),
              ],
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Mot de passe actuel',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusMd)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  hintText: 'Min. 8 caractères',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusMd)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (v.length < 8) return 'Minimum 8 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmer le nouveau mot de passe',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusMd)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (v != _newController.text) return 'Les mots de passe ne correspondent pas';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Modifier le mot de passe'),
        ),
      ],
    );
  }
}
