import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() => runApp(const NEGsAppV3());

// ============================================
// NEG's - Design System Colors
// ============================================
const _cream    = Color(0xFFF8F6F2);
const _violet   = Color(0xFF7C3AED);
const _violetD  = Color(0xFF4C1D95);
const _cyan     = Color(0xFF06B6D4);
const _cyanD    = Color(0xFF0891B2);
const _green    = Color(0xFF10B981);
const _textDark = Color(0xFF1A1A2E);
const _textGrey = Color(0xFF6B7280);
const _textMid  = Color(0xFF4B5563);

class NEGsAppV3 extends StatefulWidget {
  const NEGsAppV3({super.key});

  @override
  State<NEGsAppV3> createState() => _NEGsAppV3State();
}

class _NEGsAppV3State extends State<NEGsAppV3> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NEG's - Votre Vie Financière",
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _cream,
        primaryColor: _violet,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: NEGsHomeV3(
        logoAnimationController: _logoAnimationController,
        onThemeChange: () {
          setState(() => isDarkMode = !isDarkMode);
        },
      ),
    );
  }
}

class NEGsHomeV3 extends StatefulWidget {
  final AnimationController logoAnimationController;
  final VoidCallback onThemeChange;

  const NEGsHomeV3({
    super.key,
    required this.logoAnimationController,
    required this.onThemeChange,
  });

  @override
  State<NEGsHomeV3> createState() => _NEGsHomeV3State();
}

class _NEGsHomeV3State extends State<NEGsHomeV3> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreenV3(onThemeChange: widget.onThemeChange),
      const CardsScreenV3(),
      const CryptoScreenV3(),
      const GagnerScreenV3(),
      const ProfileScreenV3(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return LoginScreenV3(
        logoAnimationController: widget.logoAnimationController,
        onLoginSuccess: () {
          setState(() => _isLoggedIn = true);
        },
      );
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildGlassNavBar(),
    );
  }

  Widget _buildGlassNavBar() {
    return ClipPath(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: _cream.withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(color: _violet.withValues(alpha: 0.15)),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Colors.transparent,
            selectedItemColor: _violet,
            unselectedItemColor: _textGrey,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
              BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Cartes'),
              BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'Crypto'),
              BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Gagner'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// LOGIN SCREEN - GLASSMORPHISME NEG's
// ============================================
class LoginScreenV3 extends StatefulWidget {
  final AnimationController logoAnimationController;
  final VoidCallback onLoginSuccess;

  const LoginScreenV3({
    super.key,
    required this.logoAnimationController,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreenV3> createState() => _LoginScreenV3State();
}

class _LoginScreenV3State extends State<LoginScreenV3>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_cream, _cream, _cream],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            _buildAnimatedBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ANIMATED LOGO
                    ScaleTransition(
                      scale: Tween(begin: 0.95, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _pulseController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_violet, _cyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: _violet.withValues(alpha: 0.35),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: _cyan.withValues(alpha: 0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('💎', style: TextStyle(fontSize: 55)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_violet, _cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        "NEG's",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Votre vie financière, notre priorité',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildGlassTextField(
                      controller: emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    _buildGlassTextField(
                      controller: passwordController,
                      hintText: 'Mot de passe',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_violet, _cyan],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _violet.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Entrer dans NEG's",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
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

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.2).animate(_pulseController),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _violet.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: ScaleTransition(
              scale: Tween(begin: 1.2, end: 0.8).animate(_pulseController),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _cyan.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _violet.withValues(alpha: 0.2)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscurePassword : false,
            style: const TextStyle(color: _textDark),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: _textGrey),
              prefixIcon: Icon(icon, color: _violet),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: _violet,
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    setState(() => isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isLoading = false);
        widget.onLoginSuccess();
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

// ============================================
// DASHBOARD V3 - GLASSMORPHISME NEG's
// ============================================
class DashboardScreenV3 extends StatelessWidget {
  final VoidCallback onThemeChange;

  const DashboardScreenV3({super.key, required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_cream, _cream],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_violet, _cyan],
                    ).createShader(bounds),
                    child: const Text(
                      "NEG's",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  _buildGlassIconButton(Icons.brightness_4, onThemeChange),
                ],
              ),
              const SizedBox(height: 28),
              _buildGlassBalanceCard(),
              const SizedBox(height: 32),
              const Text(
                'Actions rapides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton('Virement', Icons.arrow_upward,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()))),
                  _buildActionButton('QR Code', Icons.qr_code,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScreen()))),
                  _buildActionButton('Factures', Icons.receipt,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacturesScreen()))),
                  _buildActionButton('Abonnements', Icons.subscriptions,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AbonnementsScreen()))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton('Bénéficiaires', Icons.people_outline,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeneficiairesScreen()))),
                  _buildActionButton('Convertir', Icons.currency_exchange,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConvertisseurScreen()))),
                  _buildActionButton('Partage', Icons.group_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartageScreen()))),
                  _buildActionButton('Assistant', Icons.chat_bubble_outline,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Mode Étudiant',
                      Icons.school_rounded,
                      color: const Color(0xFF6C63FF),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ModeEtudiantScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Transactions récentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildTransactionItem('Netflix', '-€12.99', '🎬', Colors.red),
              _buildTransactionItem('Salaire', '+€3,000', '💰', _green),
              _buildTransactionItem('Amazon', '-€45.50', '📦', Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton(IconData icon, VoidCallback onPressed) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _violet.withValues(alpha: 0.2)),
          ),
          child: IconButton(
            icon: Icon(icon, color: _cyan),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBalanceCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _violet.withValues(alpha: 0.15),
                _cyan.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _violet.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: _violet.withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Solde total',
                style: TextStyle(
                  color: _textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '€12 450,50',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carte Principale',
                        style: TextStyle(
                          color: _textDark.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '•••• 1234',
                        style: TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _cyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'Valide',
                      style: TextStyle(
                        color: _cyan,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, {VoidCallback? onTap, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _violet.withValues(alpha: 0.15)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap ?? () {},
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Icon(icon, color: color ?? _violet, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: _textMid,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String name,
    String amount,
    String emoji,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _violet.withValues(alpha: 0.12)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Aujourd'hui",
                        style: TextStyle(
                          color: _textDark.withValues(alpha: 0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// CARDS V3 - NEG's
// ============================================
class CardsScreenV3 extends StatefulWidget {
  const CardsScreenV3({super.key});

  @override
  State<CardsScreenV3> createState() => _CardsScreenV3State();
}

class _CardsScreenV3State extends State<CardsScreenV3> {
  late PageController _pageController;
  int _currentCard = 0;
  int _themeIndex = 0;

  // 6 card themes — used by _buildModernCard and CardCustomizerSheet
  static const List<List<Color>> cardThemes = [
    [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFF06B6D4)], // Nuit violette
    [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF38BDF8)], // Océan
    [Color(0xFF14532D), Color(0xFF16A34A), Color(0xFF4ADE80)], // Forêt
    [Color(0xFF9A3412), Color(0xFFEA580C), Color(0xFFFBBF24)], // Coucher de soleil
    [Color(0xFF9D174D), Color(0xFFDB2777), Color(0xFFF9A8D4)], // Rose gold
    [Color(0xFF111827), Color(0xFF374151), Color(0xFF9CA3AF)], // Onyx
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_cream, _cream],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_violet, _cyan],
                ).createShader(bounds),
                child: const Text(
                  'Mes Cartes',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 280,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentCard = index),
                  itemCount: 2,
                  itemBuilder: (context, index) => _buildModernCard(index),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (index) => Container(
                      width: _currentCard == index ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: _currentCard == index
                            ? _violet
                            : _textGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Fonctionnalités',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem('💳 Tap & Pay', 'Paiement sans contact'),
              _buildFeatureItem('🌍 International', '+200 pays'),
              _buildFeatureItem('🔒 Sécurisé', 'Biométrie + PIN'),
              const SizedBox(height: 24),
              _gradientButton('🎨 Personnaliser ma carte', () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CardCustomizerSheet(
                    currentTheme: _themeIndex,
                    onSelect: (i) => setState(() => _themeIndex = i),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(int index) {
    // Card 0 uses the selected theme; Card 1 always cyan
    final colors = index == 0
        ? cardThemes[_themeIndex]
        : const [_cyan, _cyanD];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.45),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "NEG's Card",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.credit_card, color: Colors.white70),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '4532 •••• •••• ${2000 + index * 500}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITULAIRE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Jean Dupont',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'EXPIRE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      '04/26',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _violet.withValues(alpha: 0.12)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: _textDark.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: _textGrey.withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// ============================================
// ANALYTICS V3 - NEG's
// ============================================
class AnalyticsScreenV3 extends StatelessWidget {
  const AnalyticsScreenV3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_cream, _cream],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_violet, _cyan],
                ).createShader(bounds),
                child: const Text(
                  'Analyse',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildAnalyticsCard('Dépenses', '€2 340', Colors.red, 68),
              _buildAnalyticsCard('Épargne', '€5 200', _green, 45),
              _buildAnalyticsCard('Investissements', '€1 200', _violet, 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String amount,
    Color color,
    int percentage,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      amount,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor: _textDark.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: _textDark.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// PROFILE V3 - NEG's
// ============================================
class ProfileScreenV3 extends StatelessWidget {
  const ProfileScreenV3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_cream, _cream],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_violet, _cyan],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: _violet.withValues(alpha: 0.35),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('👤', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_violet, _cyan],
                      ).createShader(bounds),
                      child: const Text(
                        'Jean Dupont',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'Membre Premium',
                      style: TextStyle(color: _textGrey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingItem('🔐 Sécurité', 'Gérer la sécurité'),
              _buildSettingItem('🔔 Notifications', 'Préférences d\'alertes'),
              _buildSettingItem('🌍 Langue', 'Français'),
              _buildSettingItem('💬 Support', 'Nous contacter'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _violet.withValues(alpha: 0.12)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _textDark.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: _textGrey.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// CRYPTO SCREEN V3 - NEG's
// ============================================

class _CryptoPricePainter extends CustomPainter {
  final List<double> prices;
  final Color color;
  const _CryptoPricePainter({required this.prices, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;
    final min = prices.reduce((a, b) => a < b ? a : b);
    final max = prices.reduce((a, b) => a > b ? a : b);
    final range = (max - min) == 0 ? 1.0 : max - min;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < prices.length; i++) {
      final x = i / (prices.length - 1) * size.width;
      final y = size.height - ((prices[i] - min) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CryptoScreenV3 extends StatefulWidget {
  const CryptoScreenV3({super.key});

  @override
  State<CryptoScreenV3> createState() => _CryptoScreenV3State();
}

class _CryptoScreenV3State extends State<CryptoScreenV3> {
  int _selectedCrypto = 0;
  bool _isBuy = true;
  final _amountController = TextEditingController();

  final List<Map<String, dynamic>> _cryptos = [
    {
      'name': 'Bitcoin',    'symbol': 'BTC', 'emoji': '₿',
      'price': 62450.00,    'change': 2.4,
      'held': 0.0025,
      'prices': [60000.0, 61200.0, 59800.0, 63000.0, 62100.0, 64000.0, 62450.0],
    },
    {
      'name': 'Ethereum',   'symbol': 'ETH', 'emoji': 'Ξ',
      'price': 3240.50,     'change': -1.2,
      'held': 0.15,
      'prices': [3100.0, 3300.0, 3150.0, 3400.0, 3250.0, 3200.0, 3240.5],
    },
    {
      'name': 'Solana',     'symbol': 'SOL', 'emoji': '◎',
      'price': 142.80,      'change': 5.7,
      'held': 2.0,
      'prices': [120.0, 130.0, 128.0, 145.0, 138.0, 140.0, 142.8],
    },
    {
      'name': 'BNB',        'symbol': 'BNB', 'emoji': '🔶',
      'price': 580.20,      'change': 0.8,
      'held': 0.5,
      'prices': [560.0, 570.0, 565.0, 590.0, 580.0, 575.0, 580.2],
    },
    {
      'name': 'Cardano',    'symbol': 'ADA', 'emoji': '🔵',
      'price': 0.452,       'change': -0.5,
      'held': 500.0,
      'prices': [0.44, 0.46, 0.45, 0.47, 0.44, 0.46, 0.452],
    },
    {
      'name': 'Dogecoin',   'symbol': 'DOGE','emoji': '🐕',
      'price': 0.128,       'change': 3.1,
      'held': 1000.0,
      'prices': [0.11, 0.12, 0.115, 0.13, 0.125, 0.122, 0.128],
    },
  ];

  double get _cryptoEquivalent {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final price = _cryptos[_selectedCrypto]['price'] as double;
    return price > 0 ? amount / price : 0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _cryptos[_selectedCrypto];
    final isPositive = (c['change'] as double) >= 0;
    final chartColor = isPositive ? _green : Colors.red;

    return Container(
      color: _cream,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [_violet, _cyan],
                ).createShader(b),
                child: const Text(
                  'Crypto',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // Horizontal scroll list
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cryptos.length,
                  itemBuilder: (context, i) {
                    final crypto = _cryptos[i];
                    final pos = (crypto['change'] as double) >= 0;
                    final selected = i == _selectedCrypto;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCrypto = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(colors: [_violet, _cyan])
                              : null,
                          color: selected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? Colors.transparent : _violet.withValues(alpha: 0.15),
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: _violet.withValues(alpha: 0.3), blurRadius: 12)]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(crypto['emoji'] as String,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(crypto['symbol'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: selected ? Colors.white : _textDark,
                                )),
                            Text(
                              '${pos ? '+' : ''}${crypto['change']}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: selected
                                    ? Colors.white70
                                    : (pos ? _green : Colors.red),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Price card with chart
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _violet.withValues(alpha: 0.15)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${c['emoji']} ${c['name']}',
                                    style: const TextStyle(
                                        color: _textGrey, fontSize: 13, fontWeight: FontWeight.w600)),
                                Text(
                                  '\$${(c['price'] as double) >= 1 ? (c['price'] as double).toStringAsFixed(2) : (c['price'] as double).toStringAsFixed(4)}',
                                  style: const TextStyle(
                                      fontSize: 32, fontWeight: FontWeight.w900, color: _textDark),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (isPositive ? _green : Colors.red).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${isPositive ? '+' : ''}${c['change']}%',
                                style: TextStyle(
                                    color: isPositive ? _green : Colors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 100,
                          child: CustomPaint(
                            size: const Size(double.infinity, 100),
                            painter: _CryptoPricePainter(
                              prices: List<double>.from(c['prices'] as List),
                              color: chartColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Buy / Sell toggle + amount
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _violet.withValues(alpha: 0.15)),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        // Toggle
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isBuy = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: _isBuy
                                        ? const LinearGradient(colors: [_green, Color(0xFF059669)])
                                        : null,
                                    color: _isBuy ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: _isBuy
                                        ? null
                                        : Border.all(color: _textGrey.withValues(alpha: 0.3)),
                                  ),
                                  child: Center(
                                    child: Text('Acheter',
                                        style: TextStyle(
                                          color: _isBuy ? Colors.white : _textGrey,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isBuy = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isBuy ? Colors.red : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: !_isBuy
                                        ? null
                                        : Border.all(color: _textGrey.withValues(alpha: 0.3)),
                                  ),
                                  child: Center(
                                    child: Text('Vendre',
                                        style: TextStyle(
                                          color: !_isBuy ? Colors.white : _textGrey,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Amount field
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 18),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Montant en €',
                            hintStyle: TextStyle(color: _textGrey.withValues(alpha: 0.6)),
                            prefixIcon: const Icon(Icons.euro, color: _violet),
                            filled: true,
                            fillColor: _cream,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_amountController.text.isNotEmpty)
                          Text(
                            '≈ ${_cryptoEquivalent.toStringAsFixed(6)} ${c['symbol']}  •  Frais : 0,5%',
                            style: const TextStyle(color: _textGrey, fontSize: 12),
                          ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isBuy ? [_green, const Color(0xFF059669)] : [Colors.red, const Color(0xFFB91C1C)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {},
                              child: Text(
                                _isBuy ? 'Acheter ${c['symbol']}' : 'Vendre ${c['symbol']}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Portfolio
              const Text('Mon portefeuille',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
              const SizedBox(height: 12),
              ..._cryptos.map((crypto) {
                final held = crypto['held'] as double;
                final price = crypto['price'] as double;
                final value = held * price;
                final pos = (crypto['change'] as double) >= 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _violet.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Text(crypto['emoji'] as String, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(crypto['symbol'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: _textDark)),
                              Text('${held.toStringAsFixed(held < 1 ? 4 : 2)} ${crypto['symbol']}',
                                  style: const TextStyle(color: _textGrey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('€${value.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: _textDark)),
                            Text(
                              '${pos ? '+' : ''}${crypto['change']}%',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: pos ? _green : Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// GAGNER SCREEN V3 - NEG's
// ============================================

class GagnerScreenV3 extends StatefulWidget {
  const GagnerScreenV3({super.key});

  @override
  State<GagnerScreenV3> createState() => _GagnerScreenV3State();
}

class _GagnerScreenV3State extends State<GagnerScreenV3>
    with TickerProviderStateMixin {
  int _coins = 1250;
  int _adCountdown = 0;
  bool _adRunning = false;
  late AnimationController _wheelController;
  bool _wheelSpinning = false;
  int? _wheelResult;

  // Quiz state
  bool _quizActive = false;
  int _quizIndex = 0;
  final List<Map<String, dynamic>> _questions = [
    {'q': 'Qu\'est-ce qu\'un taux directeur ?', 'a': 1,
      'opts': ['Le taux d\'une carte bancaire', 'Le taux fixé par une banque centrale', 'Le taux d\'un prêt immobilier', 'Le taux d\'un livret A']},
    {'q': 'Qu\'est-ce que l\'inflation ?', 'a': 2,
      'opts': ['La hausse des salaires', 'La baisse des prix', 'La hausse générale des prix', 'La croissance du PIB']},
    {'q': 'Qu\'est-ce qu\'un ETF ?', 'a': 0,
      'opts': ['Fonds indiciel coté en bourse', 'Emprunt à taux fixe', 'Épargne à terme fixe', 'Effet de levier financier']},
    {'q': 'Le Bitcoin est limité à combien d\'unités ?', 'a': 2,
      'opts': ['10 millions', '100 millions', '21 millions', '50 millions']},
    {'q': 'Qu\'est-ce qu\'un dividende ?', 'a': 3,
      'opts': ['Une taxe sur les actions', 'Un frais de courtage', 'Une perte boursière', 'Une part du bénéfice distribuée aux actionnaires']},
  ];

  // Scratch card state
  List<bool> _scratched = List.filled(9, false);
  List<int> _scratchValues = [];
  bool _scratchRevealed = false;

  // Wheel prizes
  final List<int> _wheelPrizes = [0, 50, 100, 200, 500, 150, 75, 25, 1000];

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _generateScratchCard();
  }

  void _generateScratchCard() {
    final prizes = [0, 0, 0, 50, 50, 100, 100, 150, 200];
    prizes.shuffle();
    _scratchValues = prizes;
    _scratched = List.filled(9, false);
    _scratchRevealed = false;
  }

  void _startAd(int seconds, int reward) {
    if (_adRunning) return;
    setState(() {
      _adRunning = true;
      _adCountdown = seconds;
    });
    _tickAd(reward);
  }

  void _tickAd(int reward) {
    if (!mounted) return;
    if (_adCountdown <= 0) {
      setState(() {
        _adRunning = false;
        _coins += reward;
      });
      _showReward(reward);
      return;
    }
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _adCountdown--);
      _tickAd(reward);
    });
  }

  void _spinWheel() {
    if (_wheelSpinning) return;
    setState(() {
      _wheelSpinning = true;
      _wheelResult = null;
    });
    _wheelController.forward(from: 0).then((_) {
      if (!mounted) return;
      final prize = _wheelPrizes[DateTime.now().millisecond % _wheelPrizes.length];
      setState(() {
        _wheelSpinning = false;
        _wheelResult = prize;
        _coins += prize;
      });
    });
  }

  void _showReward(int coins) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+$coins coins gagnés ! 🎉'),
        backgroundColor: _green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _answerQuiz(int choice) {
    final correct = _questions[_quizIndex]['a'] as int;
    if (choice == correct) {
      setState(() => _coins += 50);
      _showReward(50);
    }
    if (_quizIndex + 1 >= _questions.length) {
      setState(() {
        _quizActive = false;
        _quizIndex = 0;
      });
    } else {
      setState(() => _quizIndex++);
    }
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _cream,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + coins badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (b) =>
                        const LinearGradient(colors: [_violet, _cyan]).createShader(b),
                    child: const Text(
                      'Gagner',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_violet, _cyan]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: _violet.withValues(alpha: 0.3), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '$_coins',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('1 000 coins = 1 €',
                  style: TextStyle(color: _textGrey, fontSize: 12, fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),

              // ── Publicités ──
              _sectionTitle('📺 Publicités'),
              const SizedBox(height: 12),
              _adButton(
                label: 'Pub courte (30s)',
                reward: 50,
                seconds: 30,
                icon: Icons.play_circle_outline,
              ),
              const SizedBox(height: 10),
              _adButton(
                label: 'Pub vidéo (90s)',
                reward: 150,
                seconds: 90,
                icon: Icons.ondemand_video,
              ),
              if (_adRunning) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    minHeight: 6,
                    backgroundColor: _violet.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(_violet),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Pub en cours… $_adCountdown s restantes',
                    style: const TextStyle(color: _violet, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // ── Quiz ──
              _sectionTitle('🧠 Quiz Finance'),
              const SizedBox(height: 12),
              if (!_quizActive)
                _glassButton(
                  label: 'Lancer le quiz (+50 coins/bonne réponse)',
                  onTap: () => setState(() {
                    _quizActive = true;
                    _quizIndex = 0;
                  }),
                )
              else
                _buildQuiz(),
              const SizedBox(height: 28),

              // ── Roue ──
              _sectionTitle('🎡 Roue de fortune'),
              const SizedBox(height: 12),
              _buildWheel(),
              const SizedBox(height: 28),

              // ── Ticket à gratter ──
              _sectionTitle('🎟️ Ticket à gratter'),
              const SizedBox(height: 12),
              _buildScratchCard(),
              const SizedBox(height: 28),

              // ── Conversion ──
              _sectionTitle('💸 Convertir mes coins'),
              const SizedBox(height: 12),
              _buildConversion(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark),
      );

  Widget _adButton({required String label, required int reward, required int seconds, required IconData icon}) {
    return GestureDetector(
      onTap: _adRunning ? null : () => _startAd(seconds, reward),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _violet.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_violet, _cyan]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(color: _textDark, fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('+$reward 🪙',
                  style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_violet, _cyan]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: _violet.withValues(alpha: 0.25), blurRadius: 12)],
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    final q = _questions[_quizIndex];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _violet.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ${_quizIndex + 1}/${_questions.length}',
              style: const TextStyle(color: _textGrey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(q['q'] as String,
              style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 14),
          ...(q['opts'] as List<String>).asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => _answerQuiz(e.key),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: _cream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _violet.withValues(alpha: 0.2)),
                    ),
                    child: Text(e.value,
                        style: const TextStyle(color: _textDark, fontWeight: FontWeight.w500)),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _violet.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          RotationTransition(
            turns: Tween(begin: 0.0, end: 5.0).animate(
              CurvedAnimation(parent: _wheelController, curve: Curves.easeOut),
            ),
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(colors: [
                  _violet, _cyan, _green, Colors.orange,
                  Colors.red, _violet, _cyan, _green,
                ]),
                boxShadow: [BoxShadow(color: _violet.withValues(alpha: 0.3), blurRadius: 20)],
              ),
              child: const Center(
                child: Text('🎡', style: TextStyle(fontSize: 50)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_wheelResult != null)
            Text(
              _wheelResult! > 0 ? 'Gagné : $_wheelResult 🪙 🎉' : 'Pas de chance !',
              style: TextStyle(
                color: _wheelResult! > 0 ? _green : _textGrey,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 12),
          _glassButton(
            label: _wheelSpinning ? 'En cours…' : 'Faire tourner',
            onTap: _spinWheel,
          ),
        ],
      ),
    );
  }

  Widget _buildScratchCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _violet.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: 9,
            itemBuilder: (context, i) {
              final revealed = _scratched[i];
              return GestureDetector(
                onTap: () {
                  if (!revealed) {
                    setState(() => _scratched[i] = true);
                    if (_scratchValues.isNotEmpty && _scratchValues[i] > 0) {
                      _coins += _scratchValues[i];
                    }
                    if (_scratched.every((s) => s)) {
                      setState(() => _scratchRevealed = true);
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: revealed
                        ? LinearGradient(colors: [_cream, _cream])
                        : const LinearGradient(colors: [_violet, _cyan]),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _violet.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: revealed
                        ? Text(
                            _scratchValues[i] > 0 ? '+${_scratchValues[i]}🪙' : '😢',
                            style: TextStyle(
                              color: _scratchValues[i] > 0 ? _green : _textGrey,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          )
                        : const Icon(Icons.touch_app, color: Colors.white, size: 20),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (_scratchRevealed) ...[
            const Text('Carte terminée !', style: TextStyle(color: _textGrey)),
            const SizedBox(height: 8),
            _glassButton(
              label: 'Nouveau ticket',
              onTap: () => setState(_generateScratchCard),
            ),
          ] else
            const Text('Touchez les cases pour gratter',
                style: TextStyle(color: _textGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildConversion() {
    double euroEquivalent = _coins / 1000.0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _violet.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_coins 🪙', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
              const Icon(Icons.arrow_forward, color: _violet),
              Text('${euroEquivalent.toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _green)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _coins >= 1000
                ? 'Vous pouvez convertir ${(euroEquivalent).toStringAsFixed(2)} €'
                : 'Minimum 1 000 coins requis',
            style: TextStyle(
              color: _coins >= 1000 ? _green : Colors.red,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          _glassButton(
            label: _coins >= 1000
                ? 'Transférer ${euroEquivalent.toStringAsFixed(2)} € sur mon compte'
                : 'Pas assez de coins',
            onTap: _coins >= 1000
                ? () {
                    setState(() => _coins = 0);
                    _showReward(0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${euroEquivalent.toStringAsFixed(2)} € transféré sur votre compte ! ✅'),
                        backgroundColor: _green,
                      ),
                    );
                  }
                : () {},
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ────────────────────────────────────────────────────────

AppBar _negsAppBar(BuildContext context, String title) => AppBar(
      backgroundColor: _cream,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: ShaderMask(
        shaderCallback: (b) =>
            const LinearGradient(colors: [_violet, _cyan]).createShader(b),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
      ),
    );

Widget _glassCard({required Widget child, EdgeInsets? padding}) => ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _violet.withValues(alpha: 0.13)),
          ),
          child: child,
        ),
      ),
    );

Widget _gradientButton(String label, VoidCallback onTap,
        {List<Color> colors = const [_violet, _cyan]}) =>
    SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: colors.first.withValues(alpha: 0.3), blurRadius: 12)
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onTap,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ),
      ),
    );

Widget _negsField(TextEditingController ctrl, String hint, IconData icon,
        {bool obscure = false, TextInputType? type}) =>
    TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textGrey.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: _violet, size: 20),
        filled: true,
        fillColor: _cream,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _violet, width: 1.5)),
      ),
    );

// ============================================
// TRANSFER SCREEN
// ============================================
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountCtrl = TextEditingController();
  final _ibanCtrl   = TextEditingController();
  final _motifCtrl  = TextEditingController();
  int _selectedContact = -1;
  bool _sent = false;

  final List<Map<String, String>> _contacts = [
    {'name': 'Jean Dupont',    'iban': 'FR76 3000 6000 0112 3456 7890 189', 'avatar': '👨'},
    {'name': 'Sophie Martin',  'iban': 'FR76 1027 8060 0002 0076 7500 014', 'avatar': '👩'},
    {'name': 'Pierre Bernard', 'iban': 'FR76 3000 3030 0006 4905 7654 321', 'avatar': '🧔'},
    {'name': 'Marie Leclerc',  'iban': 'FR76 2004 1010 0505 0013 0053 564', 'avatar': '👩‍💼'},
  ];

  @override
  void dispose() {
    _amountCtrl.dispose(); _ibanCtrl.dispose(); _motifCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (_amountCtrl.text.isEmpty) return;
    setState(() => _sent = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Virement envoyé avec succès ✅'),
        backgroundColor: _green,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _negsAppBar(context, 'Virement'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contacts
            const Text('Bénéficiaires récents',
                style: TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _contacts.length,
                itemBuilder: (_, i) {
                  final c = _contacts[i];
                  final sel = _selectedContact == i;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedContact = i;
                        _ibanCtrl.text = c['iban']!;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: sel ? const LinearGradient(colors: [_violet, _cyan]) : null,
                        color: sel ? null : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: sel ? Colors.transparent : _violet.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(c['avatar']!, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(c['name']!.split(' ').first,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? Colors.white : _textDark)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            _glassCard(
              child: Column(
                children: [
                  _negsField(_ibanCtrl, 'IBAN destinataire', Icons.account_balance),
                  const SizedBox(height: 12),
                  _negsField(_amountCtrl, 'Montant (€)', Icons.euro,
                      type: TextInputType.number),
                  const SizedBox(height: 12),
                  _negsField(_motifCtrl, 'Motif du virement', Icons.edit_note),
                  const SizedBox(height: 18),
                  _gradientButton(
                    _sent ? 'Envoi en cours…' : 'Envoyer le virement',
                    _sent ? () {} : _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// QR CODE SCREEN
// ============================================
class QRScreen extends StatefulWidget {
  const QRScreen({super.key});
  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  bool _showScan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _negsAppBar(context, 'QR Code'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Toggle Generate / Scan
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _violet.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Expanded(child: GestureDetector(
                    onTap: () => setState(() => _showScan = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: !_showScan
                            ? const LinearGradient(colors: [_violet, _cyan])
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('Générer',
                          style: TextStyle(
                              color: !_showScan ? Colors.white : _textGrey,
                              fontWeight: FontWeight.w700))),
                    ),
                  )),
                  Expanded(child: GestureDetector(
                    onTap: () => setState(() => _showScan = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: _showScan
                            ? const LinearGradient(colors: [_violet, _cyan])
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('Scanner',
                          style: TextStyle(
                              color: _showScan ? Colors.white : _textGrey,
                              fontWeight: FontWeight.w700))),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (!_showScan) ...[
              _glassCard(child: Column(children: [
                const Text('Mon QR de paiement',
                    style: TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 20),
                Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _violet.withValues(alpha: 0.2)),
                    boxShadow: [BoxShadow(color: _violet.withValues(alpha: 0.1), blurRadius: 16)],
                  ),
                  child: CustomPaint(painter: _QRPainter(), size: const Size(200, 200)),
                ),
                const SizedBox(height: 16),
                const Text('Jean Dupont', style: TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 15)),
                const Text('FR76 3000 6000 0112 3456 7890 189',
                    style: TextStyle(color: _textGrey, fontSize: 11)),
                const SizedBox(height: 16),
                _gradientButton('Partager mon QR', () {}),
              ])),
            ] else ...[
              _glassCard(child: Column(children: [
                const Text('Scanner un QR Code',
                    style: TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 20),
                Container(
                  width: 220, height: 220,
                  decoration: BoxDecoration(
                    color: _textDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.white, size: 80),
                    Positioned(top: 16, left: 16,
                        child: Container(width: 30, height: 30,
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: _cyan, width: 3),
                                             left: BorderSide(color: _cyan, width: 3))))),
                    Positioned(top: 16, right: 16,
                        child: Container(width: 30, height: 30,
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: _cyan, width: 3),
                                             right: BorderSide(color: _cyan, width: 3))))),
                    Positioned(bottom: 16, left: 16,
                        child: Container(width: 30, height: 30,
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: _cyan, width: 3),
                                             left: BorderSide(color: _cyan, width: 3))))),
                    Positioned(bottom: 16, right: 16,
                        child: Container(width: 30, height: 30,
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: _cyan, width: 3),
                                             right: BorderSide(color: _cyan, width: 3))))),
                  ]),
                ),
                const SizedBox(height: 16),
                const Text('Pointez vers un QR Code de paiement',
                    style: TextStyle(color: _textGrey, fontSize: 13)),
                const SizedBox(height: 16),
                _gradientButton('Simuler un scan', () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('QR scanné : Sophie Martin — €25,00 ✅'),
                    backgroundColor: _green,
                  ));
                }),
              ])),
            ],
          ],
        ),
      ),
    );
  }
}

class _QRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _textDark;
    const cell = 10.0;
    final pattern = [
      [1,1,1,1,1,1,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,1,0,0,1,0,1,1,0,0,0,0,0,1],
      [1,0,1,1,1,0,1,0,1,0,1,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,0,1,0,1,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,1,0,1,0,1,0,1,1,1,0,1],
      [1,0,0,0,0,0,1,0,0,1,0,1,1,0,0,0,0,0,1],
      [1,1,1,1,1,1,1,0,1,0,1,0,1,1,1,1,1,1,1],
    ];
    final offsetX = (size.width - pattern[0].length * cell) / 2;
    final offsetY = (size.height - pattern.length * cell) / 2;
    for (int r = 0; r < pattern.length; r++) {
      for (int c = 0; c < pattern[r].length; c++) {
        if (pattern[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(offsetX + c * cell, offsetY + r * cell, cell - 1, cell - 1),
            paint,
          );
        }
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ============================================
// FACTURES SCREEN
// ============================================
class FacturesScreen extends StatefulWidget {
  const FacturesScreen({super.key});
  @override
  State<FacturesScreen> createState() => _FacturesScreenState();
}

class _FacturesScreenState extends State<FacturesScreen> {
  final List<Map<String, dynamic>> _factures = [
    {'label': 'Électricité', 'montant': 87.50, 'echeance': '15 avril', 'icon': '⚡', 'payee': false},
    {'label': 'Eau',         'montant': 34.20, 'echeance': '20 avril', 'icon': '💧', 'payee': false},
    {'label': 'Loyer',       'montant': 750.0, 'echeance': '1er mai',  'icon': '🏠', 'payee': true},
    {'label': 'Internet',    'montant': 29.99, 'echeance': '5 mai',    'icon': '📡', 'payee': false},
    {'label': 'Téléphone',   'montant': 19.99, 'echeance': '10 mai',   'icon': '📱', 'payee': true},
    {'label': 'Assurance',   'montant': 62.00, 'echeance': '30 avril', 'icon': '🛡️', 'payee': false},
  ];

  void _payer(int i) {
    setState(() => _factures[i]['payee'] = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_factures[i]['label']} payée ✅'),
      backgroundColor: _green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _negsAppBar(context, 'Factures'),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _factures.length,
        itemBuilder: (_, i) {
          final f = _factures[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: (f['payee'] as bool)
                      ? _green.withValues(alpha: 0.3)
                      : _violet.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Text(f['icon'] as String, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f['label'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: _textDark)),
                      Text('Échéance : ${f['echeance']}',
                          style: const TextStyle(color: _textGrey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${(f['montant'] as double).toStringAsFixed(2)} €',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: _textDark)),
                    const SizedBox(height: 6),
                    (f['payee'] as bool)
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6)),
                            child: const Text('Payée', style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w600)))
                        : GestureDetector(
                            onTap: () => _payer(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [_violet, _cyan]),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text('Payer',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            )),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================
// ABONNEMENTS SCREEN
// ============================================
class AbonnementsScreen extends StatefulWidget {
  const AbonnementsScreen({super.key});
  @override
  State<AbonnementsScreen> createState() => _AbonnementsScreenState();
}

class _AbonnementsScreenState extends State<AbonnementsScreen> {
  final List<Map<String, dynamic>> _abos = [
    {'label': 'Netflix',  'prix': 13.99, 'icon': '🎬', 'actif': true,  'date': '5 de chaque mois'},
    {'label': 'Spotify',  'prix': 9.99,  'icon': '🎵', 'actif': true,  'date': '12 de chaque mois'},
    {'label': 'Amazon',   'prix': 6.99,  'icon': '📦', 'actif': false, 'date': '20 de chaque mois'},
    {'label': 'Disney+',  'prix': 8.99,  'icon': '🏰', 'actif': true,  'date': '3 de chaque mois'},
    {'label': 'ChatGPT',  'prix': 20.00, 'icon': '🤖', 'actif': false, 'date': '1er de chaque mois'},
  ];

  double get _totalMensuel => _abos
      .where((a) => a['actif'] as bool)
      .fold(0.0, (s, a) => s + (a['prix'] as double));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _negsAppBar(context, 'Abonnements'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _glassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total mensuel',
                      style: TextStyle(color: _textGrey, fontWeight: FontWeight.w600)),
                  ShaderMask(
                    shaderCallback: (b) =>
                        const LinearGradient(colors: [_violet, _cyan]).createShader(b),
                    child: Text('${_totalMensuel.toStringAsFixed(2)} €',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _abos.length,
              itemBuilder: (_, i) {
                final a = _abos[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _violet.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      Text(a['icon'] as String, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['label'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: _textDark)),
                            Text(a['date'] as String,
                                style: const TextStyle(color: _textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('${(a['prix'] as double).toStringAsFixed(2)} €/mois',
                          style: const TextStyle(color: _textDark, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 10),
                      Switch(
                        value: a['actif'] as bool,
                        activeThumbColor: _violet,
                        onChanged: (v) => setState(() => _abos[i]['actif'] = v),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// BENEFICIAIRES SCREEN
// ============================================
class BeneficiairesScreen extends StatefulWidget {
  const BeneficiairesScreen({super.key});
  @override
  State<BeneficiairesScreen> createState() => _BeneficiairesScreenState();
}

class _BeneficiairesScreenState extends State<BeneficiairesScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  final List<Map<String, dynamic>> _contacts = [
    {'name': 'Jean Dupont',    'iban': 'FR76 3000 ...1234', 'avatar': '👨', 'fav': true},
    {'name': 'Sophie Martin',  'iban': 'FR76 1027 ...0014', 'avatar': '👩', 'fav': true},
    {'name': 'Pierre Bernard', 'iban': 'FR76 3000 ...4321', 'avatar': '🧔', 'fav': false},
    {'name': 'Marie Leclerc',  'iban': 'FR76 2004 ...3564', 'avatar': '👩‍💼','fav': false},
    {'name': 'Lucas Moreau',   'iban': 'FR76 1450 ...7892', 'avatar': '👦', 'fav': false},
  ];

  List<Map<String, dynamic>> get _filtered => _contacts
      .where((c) => (c['name'] as String).toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _negsAppBar(context, 'Bénéficiaires'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: _textDark),
              decoration: InputDecoration(
                hintText: 'Rechercher…',
                hintStyle: TextStyle(color: _textGrey.withValues(alpha: 0.7)),
                prefixIcon: const Icon(Icons.search, color: _violet, size: 20),
                filled: true, fillColor: _cream,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final idx = _contacts.indexOf(c);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _violet.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_violet, _cyan]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text(c['avatar'] as String,
                            style: const TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: _textDark)),
                            Text(c['iban'] as String,
                                style: const TextStyle(color: _textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          (c['fav'] as bool) ? Icons.star : Icons.star_border,
                          color: (c['fav'] as bool) ? Colors.amber : _textGrey,
                        ),
                        onPressed: () => setState(() => _contacts[idx]['fav'] = !(c['fav'] as bool)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const TransferScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [_violet, _cyan]),
                            borderRadius: BorderRadius.circular(8)),
                          child: const Text('Virer',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// CONVERTISSEUR SCREEN
// ============================================
class ConvertisseurScreen extends StatefulWidget {
  const ConvertisseurScreen({super.key});
  @override
  State<ConvertisseurScreen> createState() => _ConvertisseurScreenState();
}

class _ConvertisseurScreenState extends State<ConvertisseurScreen> {
  final _amountCtrl = TextEditingController(text: '100');
  int _fromIdx = 0;
  int _toIdx = 1;

  final List<Map<String, dynamic>> _currencies = [
    {'code': 'EUR', 'name': 'Euro',           'flag': '🇪🇺', 'rate': 1.0},
    {'code': 'USD', 'name': 'Dollar US',      'flag': '🇺🇸', 'rate': 1.08},
    {'code': 'GBP', 'name': 'Livre sterling', 'flag': '🇬🇧', 'rate': 0.86},
    {'code': 'XAF', 'name': 'Franc CFA',      'flag': '🌍', 'rate': 655.96},
    {'code': 'CAD', 'name': 'Dollar canadien','flag': '🇨🇦', 'rate': 1.47},
    {'code': 'JPY', 'name': 'Yen japonais',   'flag': '🇯🇵', 'rate': 162.50},
  ];

  double get _result {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final fromRate = _currencies[_fromIdx]['rate'] as double;
    final toRate   = _currencies[_toIdx]['rate']   as double;
    return amount / fromRate * toRate;
  }

  @override
  void dispose() { _amountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _negsAppBar(context, 'Convertisseur'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _glassCard(
              child: Column(
                children: [
                  _negsField(_amountCtrl, 'Montant', Icons.numbers,
                      type: TextInputType.number),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _currencyDropdown(_fromIdx, (v) => setState(() => _fromIdx = v!))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            final tmp = _fromIdx; _fromIdx = _toIdx; _toIdx = tmp;
                          }),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [_violet, _cyan]),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      Expanded(child: _currencyDropdown(_toIdx, (v) => setState(() => _toIdx = v!))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [_violet.withValues(alpha: 0.1), _cyan.withValues(alpha: 0.06)]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _violet.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_amountCtrl.text} ${_currencies[_fromIdx]['code']} =',
                          style: const TextStyle(color: _textGrey, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (b) =>
                              const LinearGradient(colors: [_violet, _cyan]).createShader(b),
                          child: Text(
                            '${_result.toStringAsFixed(2)} ${_currencies[_toIdx]['code']}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1 ${_currencies[_fromIdx]['code']} = ${((_currencies[_toIdx]['rate'] as double) / (_currencies[_fromIdx]['rate'] as double)).toStringAsFixed(4)} ${_currencies[_toIdx]['code']}',
                          style: const TextStyle(color: _textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _currencyDropdown(int currentIdx, void Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      initialValue: currentIdx,
      decoration: InputDecoration(
        filled: true,
        fillColor: _cream,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      items: _currencies.asMap().entries.map((e) => DropdownMenuItem<int>(
            value: e.key,
            child: Text('${e.value['flag']} ${e.value['code']}',
                style: const TextStyle(color: _textDark, fontWeight: FontWeight.w600)),
          )).toList(),
      onChanged: onChanged,
    );
  }
}

// ============================================
// PARTAGE DE DÉPENSES SCREEN
// ============================================
class PartageScreen extends StatefulWidget {
  const PartageScreen({super.key});
  @override
  State<PartageScreen> createState() => _PartageScreenState();
}

class _PartageScreenState extends State<PartageScreen> {
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final List<String> _participants = ['Moi'];
  final _partCtrl   = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose(); _amountCtrl.dispose(); _partCtrl.dispose();
    super.dispose();
  }

  double get _partPerPerson {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    return _participants.isEmpty ? 0 : amount / _participants.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _negsAppBar(context, 'Partage de dépenses'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _glassCard(
              child: Column(
                children: [
                  _negsField(_titleCtrl, 'Titre de la dépense', Icons.receipt_long),
                  const SizedBox(height: 12),
                  _negsField(_amountCtrl, 'Montant total (€)', Icons.euro,
                      type: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Participants',
                style: TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                ..._participants.map((p) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_violet, _cyan]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(p, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      if (p != 'Moi') ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _participants.remove(p)),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ],
                    ],
                  ),
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _negsField(_partCtrl, 'Ajouter un participant', Icons.person_add)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (_partCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _participants.add(_partCtrl.text.trim());
                        _partCtrl.clear();
                      });
                    }
                  },
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_violet, _cyan]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            if (_amountCtrl.text.isNotEmpty && _participants.isNotEmpty) ...[
              const SizedBox(height: 24),
              _glassCard(
                child: Column(
                  children: [
                    const Text('Répartition',
                        style: TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 16),
                    ..._participants.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p, style: const TextStyle(color: _textDark, fontWeight: FontWeight.w600)),
                          Text('${_partPerPerson.toStringAsFixed(2)} €',
                              style: const TextStyle(color: _violet, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )),
                    const Divider(),
                    _gradientButton('Envoyer les demandes de remboursement', () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Demandes envoyées ✅'),
                        backgroundColor: _green,
                      ));
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// CHATBOT IA SCREEN
// ============================================
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _inputCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Map<String, String>> _messages = [
    {'role': 'bot', 'text': 'Bonjour ! Je suis NEG\'s IA 🤖\nComment puis-je vous aider aujourd\'hui ?'},
  ];

  static const Map<String, String> _replies = {
    'solde':       '💰 Votre solde actuel est de **€12 450,50**.',
    'virement':    '📤 Pour faire un virement, allez dans Actions rapides → Virement.',
    'carte':       '💳 Vous avez 2 cartes actives : Visa •1234 et MasterCard •2500.',
    'crypto':      '₿ Votre portfolio crypto vaut actuellement **€287,40**.',
    'frais':       '📊 Vos frais ce mois-ci s\'élèvent à **€12,30**.',
    'économies':   '🏦 Vous avez économisé **€5 200** ce trimestre. Excellent !',
    'facture':     '⚡ Vous avez 3 factures en attente pour un total de **€137,49**.',
    'abonnement':  '📺 Vos abonnements actifs coûtent **€32,97/mois**.',
  };

  String _getReply(String input) {
    final lower = input.toLowerCase();
    for (final entry in _replies.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'Je n\'ai pas compris votre demande. Essayez : solde, virement, carte, crypto, frais, économies, facture ou abonnement.';
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _inputCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _messages.add({'role': 'bot', 'text': _getReply(text)}));
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    });
  }

  @override
  void dispose() { _inputCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _negsAppBar(context, 'Assistant NEG\'s IA'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isBot = m['role'] == 'bot';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment:
                        isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isBot) ...[
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [_violet, _cyan]),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isBot ? null
                                : const LinearGradient(colors: [_violet, _cyan]),
                            color: isBot ? Colors.white : null,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isBot ? 4 : 16),
                              bottomRight: Radius.circular(isBot ? 16 : 4),
                            ),
                            border: isBot ? Border.all(color: _violet.withValues(alpha: 0.12)) : null,
                          ),
                          child: Text(
                            m['text']!,
                            style: TextStyle(
                              color: isBot ? _textDark : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _violet.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    style: const TextStyle(color: _textDark),
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Posez votre question…',
                      hintStyle: TextStyle(color: _textGrey.withValues(alpha: 0.7)),
                      filled: true,
                      fillColor: _cream,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_violet, _cyan]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
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

// ─────────────────────────────────────────────
// MODE ÉTUDIANT SCREEN
// ─────────────────────────────────────────────
class ModeEtudiantScreen extends StatefulWidget {
  const ModeEtudiantScreen({super.key});
  @override
  State<ModeEtudiantScreen> createState() => _ModeEtudiantScreenState();
}

class _ModeEtudiantScreenState extends State<ModeEtudiantScreen> {
  double _monthlyBudget = 500;
  final Map<String, double> _categories = {
    'Logement': 250,
    'Alimentation': 80,
    'Transport': 40,
    'Loisirs': 60,
    'Santé': 30,
    'Divers': 40,
  };
  final Map<String, Color> _catColors = {
    'Logement': Color(0xFF7C3AED),
    'Alimentation': Color(0xFF06B6D4),
    'Transport': Color(0xFF10B981),
    'Loisirs': Color(0xFFF59E0B),
    'Santé': Color(0xFFEF4444),
    'Divers': Color(0xFF8B5CF6),
  };

  double get _totalSpent => _categories.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _negsAppBar(context, 'Mode Étudiant'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge étudiant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6C63FF).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Compte Étudiant', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Banque gratuite · Limite 500€', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('ACTIF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Budget mensuel
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Budget Mensuel', style: TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_monthlyBudget.toInt()}€ / mois',
                          style: const TextStyle(color: _violet, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Dépensé: ${_totalSpent.toInt()}€',
                          style: TextStyle(color: _totalSpent > _monthlyBudget ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _violet,
                      inactiveTrackColor: _violet.withValues(alpha: 0.15),
                      thumbColor: _violet,
                      overlayColor: _violet.withValues(alpha: 0.1),
                    ),
                    child: Slider(
                      value: _monthlyBudget,
                      min: 100,
                      max: 1500,
                      divisions: 28,
                      onChanged: (v) => setState(() => _monthlyBudget = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('100€', style: TextStyle(color: _textGrey, fontSize: 12)),
                      Text('1500€', style: TextStyle(color: _textGrey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Catégories de dépenses
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Répartition des Dépenses', style: TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  ..._categories.entries.map((entry) {
                    final pct = _monthlyBudget > 0 ? (entry.value / _monthlyBudget).clamp(0.0, 1.0) : 0.0;
                    final color = _catColors[entry.key]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Text(entry.key, style: const TextStyle(color: _textDark, fontSize: 14)),
                              ]),
                              Text('${entry.value.toInt()}€  (${(pct * 100).toInt()}%)',
                                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: color.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation(color),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Conseils étudiant
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Conseils Financiers', style: TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...[
                    ('💡', 'Mettez de côté 10% de chaque virement reçu automatiquement.'),
                    ('🛒', 'Faites vos courses en fin de journée pour les promotions.'),
                    ('📱', 'Activez les alertes de solde bas à 50€ dans vos paramètres.'),
                    ('🎓', 'Profitez des offres étudiantes sur les abonnements streaming.'),
                  ].map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip.$1, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(tip.$2, style: const TextStyle(color: _textMid, fontSize: 13))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CARD CUSTOMIZER SHEET
// ─────────────────────────────────────────────
class CardCustomizerSheet extends StatefulWidget {
  final int currentTheme;
  final void Function(int) onSelect;
  const CardCustomizerSheet({super.key, required this.currentTheme, required this.onSelect});
  @override
  State<CardCustomizerSheet> createState() => _CardCustomizerSheetState();
}

class _CardCustomizerSheetState extends State<CardCustomizerSheet> with SingleTickerProviderStateMixin {
  late int _selected;
  late AnimationController _previewCtrl;
  late Animation<double> _previewScale;

  static const List<List<Color>> _themes = [
    [Color(0xFF7C3AED), Color(0xFF06B6D4)],
    [Color(0xFF10B981), Color(0xFF3B82F6)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    [Color(0xFF0F172A), Color(0xFF334155)],
    [Color(0xFF065F46), Color(0xFF06B6D4)],
  ];
  static const List<String> _themeNames = [
    'Violet Cyan', 'Émeraude', 'Soleil', 'Rose Violet', 'Nuit', 'Forêt'
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentTheme;
    _previewCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _previewScale = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _previewCtrl, curve: Curves.easeOut));
    _previewCtrl.forward();
  }

  @override
  void dispose() {
    _previewCtrl.dispose();
    super.dispose();
  }

  void _pick(int i) {
    setState(() => _selected = i);
    _previewCtrl.reset();
    _previewCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _themes[_selected];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      decoration: const BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _textGrey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Personnaliser votre carte', style: TextStyle(color: _textDark, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Animated preview card
          ScaleTransition(
            scale: _previewScale,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Stack(
                children: [
                  Positioned(top: -20, right: -20,
                      child: Container(width: 120, height: 120,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)))),
                  Positioned(bottom: -30, left: -10,
                      child: Container(width: 100, height: 100,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)))),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('NEG\'s', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          Icon(Icons.credit_card, color: Colors.white.withValues(alpha: 0.8), size: 22),
                        ]),
                        const Spacer(),
                        const Text('•••• •••• •••• 4242', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2)),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('PRÉNOM NOM', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                          Text('12/27', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Theme grid 3×2
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _themes.length,
            itemBuilder: (_, i) {
              final selected = i == _selected;
              return GestureDetector(
                onTap: () => _pick(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _themes[i]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 2.5),
                    boxShadow: selected ? [BoxShadow(color: _themes[i][0].withValues(alpha: 0.4), blurRadius: 10)] : [],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 16),
                        Text(_themeNames[i], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Apply button
          _gradientButton('Appliquer ce thème', () {
            widget.onSelect(_selected);
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }
}
