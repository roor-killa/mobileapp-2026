import 'package:flutter/material.dart';
import 'package:fatoubank/utils/colors.dart';

class AnalyticsContent extends StatelessWidget {
  const AnalyticsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'label': 'Alimentation', 'percentage': 0.45, 'amount': '340 €', 'icon': Icons.restaurant_outlined},
      {'label': 'Transport', 'percentage': 0.30, 'amount': '220 €', 'icon': Icons.directions_car_outlined},
      {'label': 'Loisirs', 'percentage': 0.15, 'amount': '112 €', 'icon': Icons.movie_outlined},
      {'label': 'Santé', 'percentage': 0.10, 'amount': '75 €', 'icon': Icons.local_hospital_outlined},
    ];

    final List<double> weeklySpends = [120, 200, 150, 300, 180, 250, 100];
    final List<String> days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final double maxSpend = weeklySpends.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Header rouge courbé
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Statistiques', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Ce mois-ci', style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1047),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutExpo,
                    builder: (context, value, child) {
                      return Text(
                        '${value.toStringAsFixed(0)} €',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Contenu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 170),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Graphique en barres
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cette semaine', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (index) {
                              double heightRatio = weeklySpends[index] / maxSpend;
                              bool isToday = index == 4;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: 100 * heightRatio),
                                    duration: Duration(milliseconds: 600 + (index * 100)),
                                    curve: Curves.easeOutCubic,
                                    builder: (_, value, __) => Container(
                                      width: 28,
                                      height: value,
                                      decoration: BoxDecoration(
                                        color: isToday ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(days[index], style: TextStyle(fontSize: 10, color: isToday ? AppColors.primary : AppColors.textSecondary, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('CATÉGORIES', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  ...categories.map((cat) => _buildCategoryItem(cat)).toList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(cat['icon'] as IconData, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                    Text(cat['amount'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: cat['percentage'] as double,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
