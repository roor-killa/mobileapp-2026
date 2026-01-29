import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TapGameApp());
}

class TapGameApp extends StatelessWidget {
  const TapGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TapGamePage(),
    );
  }
}

class TapGamePage extends StatefulWidget {
  const TapGamePage({super.key});

  @override
  State<TapGamePage> createState() => _TapGamePageState();
}

class _TapGamePageState extends State<TapGamePage> {
  final Random random = Random();

  int score = 0;
  int timeLeft = 30;

  double x = 100;
  double y = 100;
  double size = 80;
  Color color = Colors.blue;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startGame();
    });
  }


  void startGame() {
    score = 0;
    timeLeft = 30;
    moveSquare();

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void moveSquare() {
    final screen = MediaQuery.of(context).size;

    setState(() {
      size = random.nextInt(50) + 50; // 50 → 100
      x = random.nextDouble() * (screen.width - size);
      y = random.nextDouble() * (screen.height - size - 150);
      color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    });
  }

  void tapSquare() {
    setState(() {
      score++;
    });
    moveSquare();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Tap Game Fun'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 10,
            left: 20,
            child: Text('Score : $score', style: const TextStyle(fontSize: 20)),
          ),
          Positioned(
            top: 10,
            right: 20,
            child: Text('Temps : $timeLeft', style: const TextStyle(fontSize: 20)),
          ),

          if (timeLeft > 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: x,
              top: y,
              child: GestureDetector(
                onTap: tapSquare,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          if (timeLeft == 0)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'GAME OVER',
                    style: TextStyle(fontSize: 40, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Score final : $score',
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: startGame,
                    child: const Text('Rejouer'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
