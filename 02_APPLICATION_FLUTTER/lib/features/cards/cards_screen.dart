import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/card_personalization.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({Key? key}) : super(key: key);

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentCardIndex = 0;
  double _spent = 3250;
  double _limit = 5000;
  late AnimationController _shimmerController;
  late AnimationController _particlesController;

  CardPersonalization _cardPersonalization = CardPersonalization.presets[0];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _particlesController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shimmerController.dispose();
    _particlesController.dispose();
    super.dispose();
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
              const Text(
                'Mes Cartes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // PageView Cards
              SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentCardIndex = index),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onLongPress: () => _showCardOptions(context),
                        child: _buildBankCard(index),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Dots
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: _currentCardIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentCardIndex == index
                            ? NEGsColors.primaryCyan
                            : NEGsColors.borderLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Plafond dépenses
              _buildSpendingLimit(),
              const SizedBox(height: 32),
              // Actions
              _buildQuickActions(),
              const SizedBox(height: 32),
              // Ajouter carte
              _buildAddCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankCard(int index) {
    final isVirtual = index == 1;
    return Container(
      decoration: BoxDecoration(
        gradient: _cardPersonalization.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: NEGsColors.primaryViolet.withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Shimmer effect
          if (_cardPersonalization.theme == PersonalizationTheme.gradient)
            _buildShimmerOverlay(),
          // Particles
          if (_cardPersonalization.pattern == CardPattern.particles)
            _buildParticles(),
          // Card content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isVirtual ? 'CARTE VIRTUELLE' : 'COMPTE COURANT',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text('💳', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const Spacer(),
                Text(
                  '1234 5678 9012 3456',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TITULAIRE',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Alice Dupont',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'EXPIRE',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '12/27',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // Logo
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'VISA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              left: -200,
              top: 0,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 0),
                ).animate(_shimmerController),
                child: Container(
                  width: 200,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0),
                      ],
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

  Widget _buildParticles() {
    return Positioned.fill(
      child: Stack(
        children: List.generate(
          5,
          (i) => Positioned(
            left: 20 + i * 50.0,
            top: 30 + (i % 2) * 80.0,
            child: ScaleTransition(
              scale: Tween(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: _particlesController,
                  curve: Interval(i * 0.2, 1.0, curve: Curves.easeInOut),
                ),
              ),
              child: Opacity(
                opacity: 0.4 - (i * 0.08),
                child: Container(
                  width: 4 + (i * 1.0),
                  height: 4 + (i * 1.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingLimit() {
    final percentage = _spent / _limit;
    Color barColor = Colors.green;
    if (percentage > 0.85) {
      barColor = Colors.red;
    } else if (percentage > 0.60) {
      barColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NEGsColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NEGsColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: NEGsColors.primaryViolet.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plafond de dépenses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NEGsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: NEGsColors.borderLight,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '€${_spent.toStringAsFixed(2)} / €${_limit.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NEGsColors.textPrimary,
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton('🔒', 'Bloquer'),
        _buildActionButton('⚙️', 'Paramètres'),
        _buildActionButton('📋', 'Détails'),
        _buildActionButton('📤', 'Partager'),
      ],
    );
  }

  Widget _buildActionButton(String icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: NEGsColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NEGsColors.borderLight),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: NEGsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: NEGsColors.borderLight, width: 2),
        borderRadius: BorderRadius.circular(16),
        color: NEGsColors.bgWhite.withValues(alpha: 0.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.add, size: 40, color: NEGsColors.primaryViolet),
          const SizedBox(height: 12),
          const Text(
            'Ajouter une carte virtuelle',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: NEGsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gratuit, sécurisé, instance',
            style: TextStyle(fontSize: 12, color: NEGsColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showCardOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NEGsColors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personnaliser ma carte',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'COULEURS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: NEGsColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: CardPersonalization.presets.map((preset) {
                    final isSelected = _cardPersonalization.name == preset.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _cardPersonalization = preset);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: preset.gradient,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(
                                    color: NEGsColors.primaryViolet,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: NEGsColors.primaryViolet.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
