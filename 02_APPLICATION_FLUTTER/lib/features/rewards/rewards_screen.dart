import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/constants/colors.dart';
import '../../core/constants/styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_text.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int coinsBalance = 1250;
  int level = 5;
  int experience = 750;
  bool _isGameRunning = false;
  int _gameScore = 0;

  void _watchAdReward() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NEGsColors.bgDark,
        title: const Text(
          'Ad Watching...',
          style: TextStyle(color: Colors.white),
        ),
        content: const CircularProgressIndicator(),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        setState(() => coinsBalance += 50);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Earned 50 coins! 🎉')));
      }
    });
  }

  void _playGame() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildGameDialog(),
    );
  }

  Widget _buildGameDialog() {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: NEGsColors.bgDark,
          title: const Text(
            'Tap Tap Game',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score: $_gameScore',
                style: const TextStyle(
                  color: NEGsColors.primaryCyan,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() => _gameScore++);
                  if (_gameScore >= 20) {
                    this.setState(() => coinsBalance += 100);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Won 100 coins! 🎮')),
                    );
                  }
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: NEGsGradients.mainGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      'TAP!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tap 20 times to win!',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _gameScore = 0;
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientText('Rewards & Games', style: NEGsStyles.heading2),
              const SizedBox(height: 28),
              _buildCoinsCard(),
              const SizedBox(height: 24),
              _buildLevelCard(),
              const SizedBox(height: 32),
              const Text(
                'Earn Coins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildEarnOption(
                      '🎬 Watch Ads',
                      '+50 coins',
                      _watchAdReward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEarnOption(
                      '🎮 Play Game',
                      '+100 coins',
                      _playGame,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Rewards Store',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildRewardItem(
                '🚀 Premium Features',
                200,
                'Unlock premium features',
              ),
              _buildRewardItem('💎 VIP Status', 500, 'Get VIP benefits'),
              _buildRewardItem(
                '🌟 Exclusive Card',
                1000,
                'Get exclusive metal card',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Coins',
            style: TextStyle(
              color: NEGsColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$coinsBalance',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.primaryCyan,
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: NEGsGradients.mainGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🪙', style: TextStyle(fontSize: 40)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    double progress = experience / 1000;
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Level',
                    style: TextStyle(
                      color: NEGsColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level $level',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: NEGsColors.primaryViolet,
                    ),
                  ),
                ],
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: NEGsGradients.mainGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: NEGsStyles.shadowMedium,
                ),
                child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 50)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Experience Progress',
            style: TextStyle(color: NEGsColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(
                  NEGsColors.primaryCyan,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$experience / 1000 XP',
            style: const TextStyle(
              color: NEGsColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnOption(String title, String reward, VoidCallback onTap) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: NEGsColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            reward,
            style: const TextStyle(
              color: NEGsColors.primaryCyan,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String title, int cost, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(title.substring(0, 1), style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: NEGsColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      color: NEGsColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: NEGsColors.primaryCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$cost 🪙',
                style: const TextStyle(
                  color: NEGsColors.primaryCyan,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
