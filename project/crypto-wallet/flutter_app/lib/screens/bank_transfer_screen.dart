import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

class BankTransferScreen extends StatefulWidget {
  const BankTransferScreen({super.key});

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _amountController = TextEditingController();
  final _emailNodEXController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshBalance());
  }

  void _onTabChanged() {
    if (_tab.index == 1) _refreshBalance(); // Onglet Recevoir : rafraîchir pour voir les virements reçus
  }

  Future<void> _refreshBalance() async {
    final wp = context.read<WalletProvider>();
    final auth = context.read<AuthProvider>();
    await auth.syncApiToken();
    await wp.fetch(auth.user?.id);
  }

  @override
  void dispose() {
    _tab.removeListener(_onTabChanged);
    _tab.dispose();
    _amountController.dispose();
    _emailNodEXController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virement'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Envoyer'),
            Tab(text: 'Recevoir'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildSendTab(),
          _buildReceiveTab(),
        ],
      ),
    );
  }

  Widget _buildSendTab() {
    return Consumer<WalletProvider>(
      builder: (context, wp, _) {
        final solde = wp.eurBalance;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_rounded, color: AppTheme.primary, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Compte NodEX', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                          Text('Solde : ${solde.toStringAsFixed(2).replaceAll('.', ',')} \u20AC', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final wp = context.read<WalletProvider>();
                  final msg = await wp.testConnection();
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Diagnostic'),
                      content: SingleChildScrollView(child: Text(msg)),
                      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
                    ),
                  );
                },
                icon: const Icon(Icons.bug_report_outlined, size: 18),
                label: const Text('Test connexion'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.4))),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                    SizedBox(width: 12),
                    Expanded(child: Text('Le virement passe par la base de données. Le destinataire reçoit l\'argent immédiatement. Utilisez l\'IBAN ou le pseudonyme du destinataire.', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('IBAN ou pseudonyme du destinataire', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailNodEXController,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Collez l’IBAN ou le pseudonyme (affichés chez le destinataire, onglet Recevoir)',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: Icon(Icons.account_balance_outlined, color: AppTheme.primary),
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              const Text('Montant', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: '0,00',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: Icon(Icons.euro_rounded, color: AppTheme.textSecondary),
                  suffix: Text('\u20AC', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ),
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : () async {
                    try {
                      final amt = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
                      final emailNodEX = _emailNodEXController.text.trim();
                      if (amt <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indiquez un montant valide'), backgroundColor: Colors.redAccent));
                        return;
                      }
                      if (amt > wp.eurBalance) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solde insuffisant'), backgroundColor: Colors.redAccent));
                        return;
                      }
                      if (emailNodEX.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrez l\'IBAN ou le pseudonyme du destinataire'), backgroundColor: Colors.redAccent));
                        return;
                      }
                      setState(() => _sending = true);
                      await context.read<AuthProvider>().syncApiToken();
                      if (!mounted) return;
                      final err = await wp.bankSendToNodEX(emailNodEX, amt);
                      if (!mounted) return;
                      setState(() => _sending = false);
                      if (err != null) {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Erreur virement', style: TextStyle(color: Colors.redAccent)),
                            content: SingleChildScrollView(child: Text(err)),
                            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Virement de ${amt.toStringAsFixed(2)} \u20AC envoyé. Le destinataire a reçu l\'argent.'), backgroundColor: Colors.green, duration: const Duration(seconds: 4)),
                      );
                      _amountController.clear();
                      _emailNodEXController.clear();
                    } catch (e) {
                      if (mounted) {
                        setState(() => _sending = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 5)));
                      }
                    }
                  },
                  icon: _sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
                  label: Text(_sending ? 'Envoi...' : 'Envoyer le virement', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onRefreshReceive() async {
    await _refreshBalance();
    // Petit délai pour que l'animation de refresh soit visible
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Nom sur le RIB : profil Appwrite d’abord, sinon base.
  String _titulaireRib(WalletProvider wp, AuthProvider auth) {
    final appwriteName = auth.user?.name?.trim() ?? '';
    if (appwriteName.isNotEmpty) return appwriteName;
    final dbName = wp.myHolderName?.trim() ?? '';
    if (dbName.isNotEmpty && dbName != 'Utilisateur') return dbName;
    final parts = auth.user?.email.split('@');
    if (parts != null && parts.isNotEmpty && parts.first.trim().isNotEmpty) {
      return parts.first.trim();
    }
    if (dbName.isNotEmpty) return dbName;
    return '—';
  }

  String _texteRibComplet(String titulaire, String iban, String bic, String? pseudonym) {
    final buf = StringBuffer()
      ..writeln('RIB NodEX')
      ..writeln('Titulaire : $titulaire')
      ..writeln('Domiciliation : NodEX')
      ..writeln('IBAN : $iban')
      ..writeln('BIC : $bic');
    if (pseudonym != null && pseudonym.trim().isNotEmpty) {
      buf.writeln('Pseudonyme / référence : ${pseudonym.trim()}');
    }
    return buf.toString().trim();
  }

  Widget _ribLine(String label, String value, {required bool mono}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: mono ? 'monospace' : null,
            letterSpacing: mono ? 0.6 : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiveTab() {
    return Consumer2<WalletProvider, AuthProvider>(
      builder: (context, wp, auth, _) {
        final myIban = wp.myIban ?? '';
        final myPseudonym = wp.myPseudonym;
        final titulaire = _titulaireRib(wp, auth);
        const bic = 'NODXFRPP';

        return RefreshIndicator(
          onRefresh: _onRefreshReceive,
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Recevoir des virements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Votre IBAN et pseudonyme servent à ce qu’on vous envoie de l’argent. Communiquez-les à l’expéditeur ou copiez le RIB.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.description_rounded, color: AppTheme.primary, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Votre RIB NodEX',
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ribLine('Titulaire du compte', titulaire, mono: false),
                      const SizedBox(height: 12),
                      _ribLine('Domiciliation', 'NodEX', mono: false),
                      const SizedBox(height: 12),
                      _ribLine(
                        'IBAN',
                        myIban.isNotEmpty ? myIban : '—',
                        mono: myIban.isNotEmpty,
                      ),
                      const SizedBox(height: 12),
                      _ribLine('BIC / SWIFT', bic, mono: true),
                      if ((myPseudonym ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _ribLine('Pseudonyme (référence)', myPseudonym!, mono: false),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: myIban.isEmpty
                                  ? null
                                  : () {
                                      Clipboard.setData(ClipboardData(text: myIban.replaceAll(' ', '')));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('IBAN copié'), backgroundColor: AppTheme.primary),
                                      );
                                    },
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Copier l’IBAN'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: myIban.isEmpty
                                  ? null
                                  : () {
                                      final text = _texteRibComplet(titulaire, myIban, bic, myPseudonym);
                                      Clipboard.setData(ClipboardData(text: text));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('RIB complet copié'), backgroundColor: AppTheme.primary),
                                      );
                                    },
                              icon: const Icon(Icons.content_copy_rounded, size: 18),
                              label: const Text('Copier le RIB'),
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _refreshBalance(),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Actualiser (solde + IBAN + historique)'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Historique',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                if (wp.virementsHistory.isNotEmpty) ...[
                  ...wp.virementsHistory.take(10).map((v) {
                    final type = v['type'] as String?;
                    final amt = (v['amount'] as num?)?.toDouble() ?? 0.0;
                    final date = v['date'] as String?;
                    final other = v['otherPseudonym'] as String? ?? '';
                    final isReceived = type == 'received';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isReceived ? Colors.green.withOpacity(0.1) : AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(isReceived ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isReceived ? Colors.green : Colors.orange, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isReceived ? 'Reçu de $other' : 'Envoyé à $other', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                                if (date != null) Text(DateTime.tryParse(date)?.toString().substring(0, 16) ?? date, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text('${isReceived ? '+' : '-'}${amt.toStringAsFixed(2)} €', style: TextStyle(color: isReceived ? Colors.green : Colors.orange, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Aucun virement enregistré.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),
                if (myIban.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final text = _texteRibComplet(titulaire, myIban, bic, myPseudonym);
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('RIB copié — prêt à coller dans un message'), backgroundColor: AppTheme.primary),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text('Copier le RIB pour un message'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
