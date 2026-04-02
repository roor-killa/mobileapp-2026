import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../core/constants/colors.dart';
import '../../core/models/wallet.dart';

class GagnerScreen extends StatefulWidget {
  const GagnerScreen({Key? key}) : super(key: key);

  @override
  State<GagnerScreen> createState() => _GagnerScreenState();
}

class _GagnerScreenState extends State<GagnerScreen>
   with TickerProviderStateMixin {
  late CoinWallet _wallet;
  late AnimationController _confettiController;
  int _coinsGained = 0;
  bool _showConfetti = false;

  // Ads
  int _adTimerSeconds = 0;
  late Timer _adTimer;
  bool _isWatchingAd = false;

  // Roue
  double _wheelRotation = 0;

  // Quiz
  int _quizScore = 0;
  int _quizCoins = 0;
  int _currentQuestion = 0;
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': 'Qu\'est-ce que le Bitcoin?',
      'options': ['Monnaie virtuelle', 'Banque', 'Carte de crédit', 'Jeu'],
      'correct': 0,
    },
    {
      'question': 'Quel est le cripto leader par capitalisation?',
      'options': ['Ethereum', 'Bitcoin', 'Solana', 'Cardano'],
      'correct': 1,
    },
    {
      'question': 'Qu\'est-ce que le blockchain?',
      'options': ['Un chaîne de blocs', 'Une banque', 'Un jeu', 'Une app'],
      'correct': 0,
    },
    {
      'question':
          'Qu\'est-ce que la volatilité en crypto?',
      'options': ['Variation de prix', 'Énergie', 'Bloc', 'Portefeuille'],
      'correct': 0,
    },
    {
      'question': 'Quel est le symbole du Bitcoin?',
      'options': ['₿', 'Ξ', '◎', '⧫'],
      'correct': 0,
    },
  ];
  int? _selectedAnswer;

  // Scratch ticket
  late List<bool> _scratchRevealed;
  late List<int> _scratchValues;
  int _scratchGain = 0;

  // BTC Prediction
  late Timer _predictionTimer;
  int _predictionCountdown = 0;
  bool _predictionShown = false;
  bool _predictionCorrect = false;

  @override
  void initState() {
    super.initState();
    _wallet = CoinWallet(totalCoins: 5000);
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scratchRevealed = List.filled(9, false);
    _scratchValues = List.generate(9, (_) => Random().nextInt(200));
  }

  void _showConfettiAnimation() {
    _confettiController.forward();
    setState(() => _showConfetti = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _showConfetti = false);
      _confettiController.reset();
    });
  }

  void _watchShortAd() {
    if (!_wallet.canWatchAd) return;

    setState(() {
      _isWatchingAd = true;
      _adTimerSeconds = 30;
    });

    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _adTimerSeconds--);

      if (_adTimerSeconds <= 0) {
        _adTimer.cancel();
        setState(() {
          _wallet.totalCoins += 50;
          _wallet.adsWatchedToday++;
          _coinsGained = 50;
          _isWatchingAd = false;
        });
        _showConfettiAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad complétée! +50 coins ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _watchVideoAd() {
    if (!_wallet.canWatchAd) return;

    setState(() {
      _isWatchingAd = true;
      _adTimerSeconds = 90;
    });

    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _adTimerSeconds--);

      if (_adTimerSeconds <= 0) {
        _adTimer.cancel();
        setState(() {
          _wallet.totalCoins += 150;
          _wallet.adsWatchedToday++;
          _coinsGained = 150;
          _isWatchingAd = false;
        });
        _showConfettiAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vidéo complétée! +150 coins ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _spinWheel() {
    if (!_wallet.canSpinWheel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous pouvez utilisez la roue 1x par jour'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    const prizes = [10, 25, 50, 100, 200, 500, 1000, 0];
    final randomIndex = Random().nextInt(prizes.length);
    final prize = prizes[randomIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NEGsColors.bgWhite,
        title: const Text('🎡 Roue de Fortune'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Transform.rotate(
              angle: Random().nextDouble() * 10,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NEGsColors.primaryViolet,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${prize} coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (prize > 0)
              Text(
                'Vous avez gagné $prize coins! 🎉',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              )
            else
              const Text(
                'Peut-être une autre fois...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _wallet.totalCoins += prize;
                _wallet.lastWheelDate = DateTime.now();
              });
              _showConfettiAnimation();
              Navigator.pop(context);
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _startQuiz() {
    _quizScore = 0;
    _currentQuestion = 0;
    _selectedAnswer = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: NEGsColors.bgWhite,
        title: const Text('📚 Quiz Finance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_currentQuestion + 1}/5'),
            const SizedBox(height: 12),
            Text(_quizQuestions[_currentQuestion]['question']),
            const SizedBox(height: 16),
            ..._buildQuizOptions(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuizOptions() {
    final question = _quizQuestions[_currentQuestion];
    return (question['options'] as List<String>)
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final option = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(option),
            ),
          );
        })
        .toList();
  }

  void _scratchCard() {
    if (!_wallet.canUseScratchTicket) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 3 tickets par jour'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NEGsColors.bgWhite,
        title: const Text('À Gratter'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () {
                  setState(() => _scratchRevealed[index] = true);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _scratchRevealed[index]
                        ? Colors.green
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Text(
                      _scratchRevealed[index]
                          ? '${_scratchValues[index]}'
                          : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final total = _scratchValues
                  .fold<int>(0, (sum, v) => sum + v);
              setState(() {
                _wallet.totalCoins += total;
                _wallet.scratchTicketsToday++;
                _scratchRevealed = List.filled(9, false);
                _scratchValues =
                    List.generate(9, (_) => Random().nextInt(200));
              });
              _showConfettiAnimation();
              Navigator.pop(context);
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _predictBtc() {
    if (!_wallet.canPredictBtc) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('1 prédiction par heure max'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) {
          if (_predictionCountdown == 0 && !_predictionShown) {
            _predictionCountdown = 3;
            _predictionShown = true;
            _predictionCorrect = Random().nextBool();

            _predictionTimer =
                Timer.periodic(const Duration(seconds: 1), (timer) {
              dialogSetState(() => _predictionCountdown--);
              if (_predictionCountdown <= 0) {
                timer.cancel();
              }
            });
          }

          return AlertDialog(
            backgroundColor: NEGsColors.bgWhite,
            title: const Text('📈 Prédiction BTC'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_predictionCountdown > 0 && !_predictionShown)
                  Column(
                    children: [
                      const Text('Le BTC va:'),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _wallet.lastBtcPredictionTime =
                                    DateTime.now();
                                _wallet.totalCoins +=
                                    _predictionCorrect ? 200 : 0;
                              });
                              if (_predictionCorrect) {
                                _showConfettiAnimation();
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Monter 📈'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _wallet.lastBtcPredictionTime =
                                    DateTime.now();
                                _wallet.totalCoins +=
                                    !_predictionCorrect ? 200 : 0;
                              });
                              if (!_predictionCorrect) {
                                _showConfettiAnimation();
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Baisser 📉'),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        'Résultat dans $_predictionCountdown...',
                      ),
                      const SizedBox(height: 16),
                      if (_predictionCountdown <= 0)
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              _predictionCorrect
                                  ? '✓ Correct! +200 coins'
                                  : '✗ Incorrect',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _predictionCorrect
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              child: const Text('Fermer'),
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
    _predictionCountdown = 0;
    _predictionShown = false;
  }

  void _convertCoins() {
    int selectedCoins = 1000;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          backgroundColor: NEGsColors.bgWhite,
          title: const Text('Convertir coins'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: selectedCoins.toDouble(),
                min: 1000,
                max: _wallet.totalCoins.toDouble(),
                divisions: (_wallet.totalCoins - 1000) ~/ 100,
                label: '${selectedCoins ~/ 1000} @',
                onChanged: (value) =>
                    dialogSetState(() => selectedCoins = value.toInt()),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NEGsColors.bgSecondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Conversion:'),
                    Text(
                      '${selectedCoins ~/ 1000}€',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: NEGsGradients.mainGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _wallet.totalCoins -= selectedCoins;
                        _wallet.balanceEuros +=
                            (selectedCoins / 1000);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('${selectedCoins ~/ 1000}€ transférés ✓'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Transférer vers mon compte',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gagner',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: NEGsColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: NEGsColors.primaryViolet,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🪙 ${_wallet.totalCoins}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1 000 coins = 1€',
                    style: TextStyle(
                      fontSize: 12,
                      color: NEGsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Publicités
                  const Text(
                    'Publicités',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: NEGsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _wallet.canWatchAd && !_isWatchingAd
                              ? _watchShortAd
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  _wallet.canWatchAd && !_isWatchingAd
                                      ? NEGsColors.bgWhite
                                      : Colors.grey.withValues(
                                  alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _wallet.canWatchAd && !_isWatchingAd
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '📺',
                                  style: TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Pub 30s',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '+50 coins',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (_isWatchingAd && _adTimerSeconds > 0)
                                  Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: (_adTimerSeconds / 30),
                                        minHeight: 4,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_adTimerSeconds}s',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                if (!_wallet.canWatchAd)
                                  Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      const Text(
                                        '(Limite atteinte)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _wallet.canWatchAd && !_isWatchingAd
                              ? _watchVideoAd
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  _wallet.canWatchAd && !_isWatchingAd
                                      ? NEGsColors.bgWhite
                                      : Colors.grey.withValues(
                                  alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _wallet.canWatchAd && !_isWatchingAd
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '🎬',
                                  style: TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Vidéo 90s',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '+150 coins',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Mini-jeux
                  const Text(
                    'Mini-Jeux',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: NEGsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildGameCard(
                        '📚 Quiz',
                        '+50 coins',
                        Colors.purple,
                        _startQuiz,
                      ),
                      _buildGameCard(
                        '🎡 Roue',
                        'Jusqu\'à 1000',
                        Colors.orange,
                        _spinWheel,
                      ),
                      _buildGameCard(
                        '🎫 Grattage',
                        '+200 max',
                        Colors.green,
                        _scratchCard,
                      ),
                      _buildGameCard(
                        '📊 BTC',
                        '+200 coins',
                        Colors.red,
                        _predictBtc,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Conversion
                  const Text(
                    'Convertir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: NEGsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _convertCoins,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: NEGsColors.bgWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NEGsColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Convertir coins en euros',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Minimum 1000 coins',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: NEGsColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: List.generate(
                      20,
                      (index) => Positioned(
                        left: Random().nextDouble() * 400,
                        top: Random().nextDouble() * 600 - 300,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1, end: 0)
                              .animate(_confettiController),
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 1, end: 0)
                                .animate(_confettiController),
                            child: Text(
                              ['🎉', '✨', '⭐', '🪙'][
                                  Random().nextInt(4)],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
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

  Widget _buildGameCard(
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title.split(' ')[0],
                style: const TextStyle(
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title.split(' ').skip(1).join(' '),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _adTimer.cancel();
    if (_predictionTimer.isActive) _predictionTimer.cancel();
    super.dispose();
  }
}
