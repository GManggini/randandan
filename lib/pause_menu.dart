import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const PauseMenu({
    required this.onResume,
    required this.onQuit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Pausado',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onResume,
            child: const Text('Continuar'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onQuit, child: const Text('Sair'))
        ],
      ),
    );
  }
}
