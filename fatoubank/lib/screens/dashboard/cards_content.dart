import 'package:flutter/material.dart';
import 'package:fatoubank/utils/colors.dart';

class CardsContent extends StatefulWidget {
  const CardsContent({Key? key}) : super(key: key);

  @override
  State<CardsContent> createState() => _CardsContentState();
}

class _CardsContentState extends State<CardsContent> {
  bool isCardBlocked = false;
  bool showFullNumber = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes cartes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // La Carte Premium
          GestureDetector(
            onTap: () {
              setState(() {
                showFullNumber = !showFullNumber;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCardBlocked 
                    ? [Colors.grey.shade800, Colors.grey.shade900]
                    : [AppColors.primary, AppColors.secondary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isCardBlocked 
                      ? Colors.black.withOpacity(0.5) 
                      : AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Carte Principale',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isCardBlocked)
                        const Icon(Icons.lock, color: Colors.white, size: 20)
                      else
                        const Icon(Icons.wifi, color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Puce simulée
                  Container(
                    width: 45,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade400, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange.shade400, width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    showFullNumber ? '4824  3849  8291  7392' : '4824  ••••  ••••  7392',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'TITULAIRE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ECOBANK',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'EXPIRE A FIN',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                '03/26',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Simili logo Mastercard
                              const Icon(Icons.circle, color: Colors.redAccent, size: 24),
                              Transform.translate(
                                offset: const Offset(-10, 0),
                                child: const Icon(Icons.circle, color: Colors.orange, size: 24),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Menu de gestion de la carte
          const Text(
            'Gestion de la carte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCardOption(
            icon: isCardBlocked ? Icons.lock_open : Icons.block,
            title: isCardBlocked ? 'Débloquer la carte' : 'Bloquer la carte',
            subtitle: isCardBlocked ? 'Réactiver les paiements' : 'Désactiver temporairement',
            color: isCardBlocked ? AppColors.primary : AppColors.expenseColor,
            onTap: () {
              setState(() {
                isCardBlocked = !isCardBlocked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isCardBlocked ? 'Carte bloquée avec succès' : 'Carte débloquée avec succès'),
                  backgroundColor: isCardBlocked ? AppColors.expenseColor : AppColors.incomeColor,
                ),
              );
            },
          ),
          
          _buildCardOption(
            icon: Icons.tune,
            title: 'Plafonds de paiement',
            subtitle: 'Modifier vos limites (2500€ / 30j)',
            color: AppColors.primary,
            onTap: () {
              // Action non implémentée pour l'instant
            },
          ),
          
          _buildCardOption(
            icon: Icons.pin,
            title: 'Afficher le code PIN',
            subtitle: 'Nécessite une authentification',
            color: AppColors.primary,
            onTap: () {
              // Action non implémentée 
            },
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Derniers paiements carte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildTransactionTile('Supermarché', '-87.45 €', 'Aujourd\'hui', Icons.shopping_basket),
          _buildTransactionTile('Boulangerie', '-4.50 €', 'Hier', Icons.bakery_dining),
          _buildTransactionTile('Station Service', '-65.00 €', '28 Fév 2024', Icons.local_gas_station),
          
        ],
      ),
    );
  }

  Widget _buildCardOption({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(String title, String amount, String date, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
        ],
      ),
    );
  }
}