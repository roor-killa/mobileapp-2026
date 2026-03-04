import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/design_system.dart';
import 'account_details_screen.dart';
import 'create_account_screen.dart';

/// Écran "Mes cartes" (style Figma CardsScreen).
/// Affiche les comptes comme des cartes avec sélecteur, visuel, actions et transactions.
class CardsScreen extends StatefulWidget {
  final List<Account> accounts;
  final List<Transaction> transactions;

  const CardsScreen({super.key, this.accounts = const [], this.transactions = const []});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int _selectedIndex = 0;
  bool _cardFrozen = false;

  @override
  Widget build(BuildContext context) {
    final accounts = widget.accounts;
    if (accounts.isEmpty) {
      return Scaffold(
        backgroundColor: DesignSystem.gray100,
        appBar: AppBar(
          title: const Text('Mes cartes'),
          backgroundColor: DesignSystem.gray100,
          foregroundColor: DesignSystem.gray900,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.credit_card_rounded, size: 64, color: DesignSystem.gray400),
              const SizedBox(height: 16),
              Text(
                'Aucun compte',
                style: TextStyle(fontSize: 16, color: DesignSystem.gray600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.add),
                label: const Text('Ouvrir un compte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.indigo600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final account = accounts[_selectedIndex.clamp(0, accounts.length - 1)];
    final accountTransactions = widget.transactions
        .where((t) => t.fromAccountId == account.id || t.toAccountId == account.id)
        .toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final dateFormat = DateFormat('dd/MM');

    return Scaffold(
      backgroundColor: DesignSystem.gray100,
      appBar: AppBar(
        title: const Text('Mes cartes'),
        backgroundColor: DesignSystem.gray100,
        foregroundColor: DesignSystem.gray900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final nav = Navigator.of(context);
              await nav.push(MaterialPageRoute(builder: (_) => CreateAccountScreen()));
              if (!mounted) return;
              nav.pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space24, vertical: DesignSystem.space16),
        children: [
          // Sélecteur de cartes (···· 4291)
          Row(
            children: List.generate(accounts.length, (i) {
              final isSelected = i == _selectedIndex;
              final num = accounts[i].accountNumber.length >= 4 ? accounts[i].accountNumber.substring(accounts[i].accountNumber.length - 4) : '****';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: isSelected ? DesignSystem.indigo600 : DesignSystem.gray200,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = i),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          '···· $num',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : DesignSystem.gray500),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: DesignSystem.space20),

          // Visuel carte (gradient)
          Container(
            height: 185,
            padding: const EdgeInsets.all(DesignSystem.space24),
            decoration: BoxDecoration(
              gradient: DesignSystem.cardGradient,
              borderRadius: BorderRadius.circular(DesignSystem.radius2xl),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Stack(
              children: [
                Positioned(top: -40, right: -40, child: _circle(80)),
                Positioned(bottom: -32, left: -32, child: _circle(64)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_selectedIndex == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
                            child: const Text('Par défaut', style: TextStyle(fontSize: 10, color: Colors.white)),
                          )
                        else const SizedBox(),
                        Icon(Icons.wifi_rounded, size: 20, color: Colors.white.withValues(alpha: 0.8)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Solde', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
                        Text(
                          '${account.balance.toStringAsFixed(2)} ${account.currency}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Titulaire', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
                            const Text('Carte bancaire', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('N° compte', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
                            Text(account.accountNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignSystem.space24),

          // Actions carte (Détails, Bloquer, Plus, Nouvelle carte)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardAction('Détails', Icons.credit_card_rounded, DesignSystem.indigo50, DesignSystem.indigo600, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AccountDetailsScreen(account: account)));
              }),
              _cardAction(_cardFrozen ? 'Débloquer' : 'Bloquer', Icons.lock_rounded, DesignSystem.gray200, DesignSystem.gray600, () => setState(() => _cardFrozen = !_cardFrozen)),
              _cardAction('Plus', Icons.more_horiz_rounded, DesignSystem.gray200, DesignSystem.gray600, () {}),
              _cardAction('Nouvelle', Icons.add_rounded, DesignSystem.green50, DesignSystem.green600, () async {
                final nav = Navigator.of(context);
                await nav.push(MaterialPageRoute(builder: (_) => CreateAccountScreen()));
                if (!mounted) return;
                nav.pop();
              }),
            ],
          ),
          const SizedBox(height: DesignSystem.space24),

          // Plafond mensuel (style Figma)
          Container(
            padding: const EdgeInsets.all(DesignSystem.space16),
            decoration: BoxDecoration(
              color: DesignSystem.gray50,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dépenses du mois', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignSystem.gray700)),
                    Text('${account.balance.toStringAsFixed(0)} €', style: TextStyle(fontSize: 12, color: DesignSystem.gray500)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.27,
                    minHeight: 8,
                    backgroundColor: DesignSystem.gray200,
                    valueColor: const AlwaysStoppedAnimation<Color>(DesignSystem.indigo600),
                  ),
                ),
                const SizedBox(height: 6),
                Text('27 % du plafond utilisé', style: TextStyle(fontSize: 11, color: DesignSystem.gray400)),
              ],
            ),
          ),
          const SizedBox(height: DesignSystem.space24),

          // Transactions carte
          Text('Opérations récentes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DesignSystem.gray700)),
          const SizedBox(height: 12),
          if (accountTransactions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(child: Text('Aucune opération', style: TextStyle(fontSize: 14, color: DesignSystem.gray500))),
            )
          else
            ...accountTransactions.take(10).map((t) {
              final isOut = t.fromAccountId == account.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: DesignSystem.gray200, borderRadius: BorderRadius.circular(DesignSystem.radiusLg)),
                      child: Icon(isOut ? Icons.call_made_rounded : Icons.call_received_rounded, color: DesignSystem.gray600, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.description.isEmpty ? 'Opération' : t.description, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DesignSystem.gray900)),
                          Text(dateFormat.format(t.transactionDate), style: const TextStyle(fontSize: 12, color: DesignSystem.gray400)),
                        ],
                      ),
                    ),
                    Text(
                      '${isOut ? '−' : '+'}${t.amount.toStringAsFixed(2)} €',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isOut ? DesignSystem.gray800 : DesignSystem.green600),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
    );
  }

  Widget _cardAction(String label, IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(DesignSystem.radiusLg)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: DesignSystem.gray600)),
        ],
      ),
    );
  }
}
