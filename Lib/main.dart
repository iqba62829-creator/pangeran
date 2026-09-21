import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Dino Game',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Variabel Game (Sama seperti di skrip HTML)
  double y = 0;
  double v = 0;
  double x = 280;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    startGameLoop();
  }

  void startGameLoop() {
    // Game Loop setiap 20ms (sama dengan setInterval 20)
    gameTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        // 1. Lompat & Jatuh (Pemain)
        y += v;
        if (y > 0) {
          v -= 0.6;
        } else {
          y = 0;
          v = 0;
        }

        // 2. Musuh Jalan ke Kiri
        x -= 5;
        if (x < -20) {
          x = 280;
        }

        // 3. Tabrakan (Hitbox)
        if (x > 20 && x < 40 && y < 20) {
          gameTimer?.cancel(); // Hentikan game loop
          showGameOverDialog();
        }
      });
    });
  }

  void jump() {
    if (y == 0) {
      setState(() {
        v = 9;
      });
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Main Lagi'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      x = 280;
      y = 0;
      v = 0;
    });
    startGameLoop();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      body: GestureDetector(
        onTap: jump, // Ketuk layar untuk loncat
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ketuk untuk Loncat!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // Arena Game (300 x 100)
            Center(
              child: Container(
                width: 300,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF333333),
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 3),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Pemain (Kotak Cyan 20x20)
                    Positioned(
                      left: 20,
                      bottom: y,
                      child: Container(
                        width: 20,
                        height: 20,
                        color: Colors.cyan,
                      ),
                    ),

                    // Musuh (Kotak Merah 15x20)
                    Positioned(
                      left: x,
                      bottom: 0,
                      child: Container(
                        width: 15,
                        height: 20,
                        color: Colors.red,
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
