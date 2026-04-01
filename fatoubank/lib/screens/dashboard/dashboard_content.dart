import 'package:flutter/material.dart';
import 'package:fatoubank/utils/colors.dart';
import 'package:fatoubank/models/transaction.dart';
import 'package:fatoubank/widgets/transaction_card.dart';
import 'package:fatoubank/screens/dashboard/qr_code_screen.dart';
import 'package:fatoubank/screens/dashboard/history_screen.dart';
import 'package:fatoubank/screens/dashboard/ai_assistant_screen.dart';

class DashboardContent extends StatefulWidget {
  final double balance;
  final List<Transaction> transactions;
  final List<String> beneficiaries;

  const DashboardContent({
    Key? key,
    required this.balance,
    required this.transactions,
    required this.beneficiaries,
  }) : super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card (extends under the red header)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF3333), AppColors.primary, Color(0xFF990000)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Solde total', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Row(
                      children: [
                        Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(color: Color(0xFFEA001B), shape: BoxShape.circle),
                        ),
                        Transform.translate(
                          offset: const Offset(-8, 0),
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(color: const Color(0xFFF79E1B).withValues(alpha: 0.85), shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widget.balance),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutExpo,
                  builder: (_, val, __) => Text(
                    '${val.toStringAsFixed(2)} €',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        const Text('TITULAIRE', style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        const Text('ECOBANK', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('EXPIRE', style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1.2)),
                        SizedBox(height: 4),
                        Text('03/26', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('4824  ••••  ••••  7392', style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 3, fontFamily: 'monospace')),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickAction(Icons.arrow_upward_rounded, 'Envoyer'),
                _buildQuickAction(Icons.arrow_downward_rounded, 'Recevoir'),
                _buildQuickAction(Icons.qr_code_scanner, 'Scanner', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const QRCodeScreen()));
                }),
                _buildQuickAction(Icons.history, 'Historique', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(transactions: widget.transactions)));
                }),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Beneficiaries
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text('Bénéficiaires', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.beneficiaries.length,
              itemBuilder: (ctx, i) {
                final name = widget.beneficiaries[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                        child: Text(
                          name.substring(0, 1),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(name.split(' ')[0], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // Transactions list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Transactions récentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                Text('Voir tout', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: widget.transactions.map((tx) => TransactionCard(transaction: tx)).toList(),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}