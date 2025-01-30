import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  final VoidCallback onStartGame;
  final VoidCallback onLoginPressed;
  final VoidCallback onSignUpPressed;
  final VoidCallback onListUsersPressed;

  const MainMenu({
    required this.onStartGame,
    required this.onLoginPressed,
    required this.onSignUpPressed,
    required this.onListUsersPressed,
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
            const Text('RANDANDAN',
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onStartGame,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 24),
              ),
              child: const Text('Iniciar Jogo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onSignUpPressed,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.green,
                textStyle: const TextStyle(fontSize: 24),
              ),
              child: const Text('Criar Conta'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onLoginPressed,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 24),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onListUsersPressed,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.purple,
                textStyle: const TextStyle(fontSize: 24),
              ),
              child: const Text('Listar Usuários'),
            ),
          ],
        ),
      ),
    );
  }
}
