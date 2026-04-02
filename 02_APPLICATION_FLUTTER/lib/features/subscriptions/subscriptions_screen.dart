import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/subscription.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late List<Subscription> _subscriptions;

  @override
  void initState() {
    super.initState();
    _subscriptions = [
      Subscription(
        id: '1',
        name: 'Netflix',
        icon: '🎬',
        monthlyPrice: 15.99,
        nextBillingDate: DateTime(2026, 4, 15),
        isActive: true,
      ),
      Subscription(
        id: '2',
        name: 'Spotify',
        icon: '🎵',
        monthlyPrice: 11.99,
        nextBillingDate: DateTime(2026, 4, 20),
        isActive: true,
      ),
      Subscription(
        id: '3',
        name: 'Amazon Prime',
        icon: '📦',
        monthlyPrice: 49.99,
        nextBillingDate: DateTime(2026, 4, 10),
        isActive: true,
      ),
      Subscription(
        id: '4',
        name: 'Disney+',
        icon: '✨',
        monthlyPrice: 8.99,
        nextBillingDate: DateTime(2026, 4, 12),
        isActive: false,
      ),
      Subscription(
        id: '5',
        name: 'Canal+',
        icon: '📺',
        monthlyPrice: 24.99,
        nextBillingDate: DateTime(2026, 4, 25),
        isActive: true,
      ),
    ];
  }

  double get _monthlyTotal {
    return _subscriptions
        .where((s) => s.isActive)
        .fold(0, (sum, s) => sum + s.monthlyPrice);
  }

  void _toggleSubscription(int index) {
    setState(() {
      _subscriptions[index].isActive = !_subscriptions[index].isActive;
    });
  }

  void _showSubscriptionDetails(Subscription subscription, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NEGsColors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: NEGsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NEGsColors.bgSecondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prix mensuel',
                    style: TextStyle(
                      fontSize: 14,
                      color: NEGsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '€${subscription.monthlyPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: NEGsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Prochain prélèvement',
                    style: TextStyle(
                      fontSize: 14,
                      color: NEGsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subscription.nextBillingDisplay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: NEGsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: subscription.isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subscription.isActive ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: subscription.isActive
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: subscription.isActive
                      ? null
                      : NEGsGradients.mainGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: subscription.isActive
                      ? Border.all(color: Colors.red)
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _toggleSubscription(index);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subscription.isActive
                        ? Colors.transparent
                        : Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    subscription.isActive ? 'Désactiver' : 'Réactiver',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: subscription.isActive ? Colors.red : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Abonnements',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: NEGsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NEGsColors.bgWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: NEGsColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Coût mensuel total',
                          style: TextStyle(
                            fontSize: 12,
                            color: NEGsColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '€${_monthlyTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: NEGsColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_subscriptions.where((s) => s.isActive).length}/${_subscriptions.length} actifs',
                          style: const TextStyle(
                            fontSize: 12,
                            color: NEGsColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _subscriptions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.subscriptions,
                            size: 48,
                            color: NEGsColors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Aucun abonnement',
                            style: TextStyle(
                              fontSize: 16,
                              color: NEGsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _subscriptions.length,
                      itemBuilder: (context, index) {
                        final subscription = _subscriptions[index];
                        return GestureDetector(
                          onTap: () =>
                              _showSubscriptionDetails(subscription, index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: NEGsColors.bgWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: subscription.isActive
                                    ? NEGsColors.primaryCyan
                                    : NEGsColors.borderLight,
                                width: subscription.isActive ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  subscription.icon,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subscription.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: NEGsColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Prélèvement: ${subscription.nextBillingDisplay}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: NEGsColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '€${subscription.monthlyPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: NEGsColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: subscription.isActive,
                                        onChanged: (_) =>
                                            _toggleSubscription(index),
                                        activeColor: NEGsColors.primaryCyan,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alertes de prélèvement 3 jours avant',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
