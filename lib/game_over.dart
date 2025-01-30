import 'package:flutter/material.dart';

class GameOverMenu extends StatelessWidget {
  final int score;
  final VoidCallback onRestart;
  final VoidCallback onQuit;
  final Future<void> Function(int score) saveScore;

  const GameOverMenu({
    required this.score,
    required this.onRestart,
    required this.onQuit,
    required this.saveScore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(66, 0, 0, 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pontuação: $score',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await saveScore(score); // Salva o score antes de reiniciar
                onRestart(); // Reinicia o jogo
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 24),
              ),
              child: const Text('Correr Novamente'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await saveScore(score); // Salva o score antes de sair
                onQuit(); // Volta ao menu principal
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.red,
                textStyle: const TextStyle(fontSize: 24),
              ),
              child: const Text('Sair para o Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
