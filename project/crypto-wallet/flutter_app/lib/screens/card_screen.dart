import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/user_card.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/api_client.dart';

/// Carte virtuelle NodEX (RIB / IBAN : onglet Virement > Recevoir).
class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  UserCard? _card;
  bool _cardLoading = true;
  bool _blocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final wp = context.read<WalletProvider>();
    await auth.syncApiToken();
    if (!mounted) return;
    await wp.fetch(auth.user?.id);
    if (!mounted) return;
    await _loadCard();
  }

  Future<void> _loadCard() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.syncApiToken();
    if (!mounted) return;
    setState(() => _cardLoading = true);
    try {
      for (var attempt = 0; attempt < 2; attempt++) {
        final res = await ApiClient().get('/card');
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          if (data.containsKey('error')) {
            if (mounted) setState(() => _card = null);
          } else {
            if (mounted) setState(() => _card = UserCard.fromJson(data));
          }
          if (mounted) setState(() => _cardLoading = false);
          return;
        }
        if (res.statusCode == 401 && attempt == 0) {
          await auth.syncApiToken();
          continue;
        }
        break;
      }
      if (mounted) setState(() => _card = null);
    } catch (_) {
      if (mounted) setState(() => _card = null);
    } finally {
      if (mounted) setState(() => _cardLoading = false);
    }
  }

  String _titulaire(WalletProvider wp, AuthProvider auth) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Carte virtuelle'),
        actions: [
          IconButton(
            tooltip: 'Actualiser la carte',
            onPressed: () async {
              await _bootstrap();
              if (!mounted) return;
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _bootstrap,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Consumer2<WalletProvider, AuthProvider>(
            builder: (context, wp, auth, _) {
              final titulaire = _titulaire(wp, auth);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Carte virtuelle NodEX',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  if (_cardLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                    )
                  else
                    Builder(
                      builder: (ctx) {
                        final isPreview = _card == null;
                        final displayCard = _card ?? UserCard.preview(holderName: titulaire);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _VirtualCardPreview(
                              card: displayCard,
                              blocked: isPreview ? false : _blocked,
                              isPreview: isPreview,
                              onTapDetails: () => _showCardDetailsDialog(ctx, displayCard, isPreview),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (!isPreview) ...[
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => setState(() => _blocked = !_blocked),
                                      icon: Icon(_blocked ? Icons.lock_open_rounded : Icons.lock_rounded),
                                      label: Text(_blocked ? 'Débloquer' : 'Bloquer'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showCardDetailsDialog(ctx, displayCard, isPreview),
                                    icon: const Icon(Icons.visibility_rounded),
                                    label: Text(isPreview ? 'Numéro & CVV (aperçu)' : 'Numéro & CVV'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCardDetailsDialog(BuildContext context, UserCard c, bool isPreview) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Détails de la carte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                if (isPreview) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
                    ),
                    child: const Text(
                      'Mode aperçu : chiffres d’exemple. Avec le serveur Laravel, vos vraies données s’affichent ici.',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.35),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.credit_card_rounded,
                  label: 'Numéro',
                  value: c.cardNumber,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: c.cardNumber.replaceAll(' ', '')));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Numéro copié'), backgroundColor: AppTheme.primary),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.person_rounded,
                  label: 'Titulaire',
                  value: c.holderName.toUpperCase(),
                  onCopy: () => Clipboard.setData(ClipboardData(text: c.holderName)),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Expiration',
                  value: c.expiry,
                  onCopy: () => Clipboard.setData(ClipboardData(text: c.expiry)),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.lock_rounded,
                  label: 'CVV',
                  value: c.cvv,
                  onCopy: () => Clipboard.setData(ClipboardData(text: c.cvv)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VirtualCardPreview extends StatelessWidget {
  final UserCard card;
  final bool blocked;
  final bool isPreview;
  final VoidCallback onTapDetails;

  const _VirtualCardPreview({
    required this.card,
    required this.blocked,
    this.isPreview = false,
    required this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    final last4 = card.last4;
    final holder = card.holderName.toUpperCase();
    return GestureDetector(
      onTap: onTapDetails,
      child: Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: blocked
                ? [Colors.grey.shade600, Colors.grey.shade800]
                : isPreview
                    ? [
                        AppTheme.primary.withValues(alpha: 0.85),
                        AppTheme.secondary.withValues(alpha: 0.75),
                      ]
                    : [AppTheme.primary, AppTheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: isPreview ? Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: (blocked ? Colors.grey : AppTheme.primary).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('NodEX', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPreview)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'APERÇU',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    Icon(blocked ? Icons.lock_rounded : Icons.contactless_rounded, color: Colors.white70, size: 28),
                  ],
                ),
              ],
            ),
            Text(
              '••••  ••••  ••••  $last4',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 3, fontFamily: 'monospace'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TITULAIRE', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      Text(
                        holder.length > 22 ? '${holder.substring(0, 22)}…' : holder,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('EXPIRE', style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text(card.expiry, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              ],
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('Appuyez pour voir le numéro complet', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                  ],
                ),
              ),
              const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
