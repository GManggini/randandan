import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class GyroscopeManager {
  // StreamController para transmitir os valores do giroscópio
  final StreamController<Map<String, double>> _gyroscopeController =
      StreamController.broadcast();

  // Getter para expor a stream dos valores
  Stream<Map<String, double>> get gyroscopeStream =>
      _gyroscopeController.stream;

  // Sensibilidade dos movimentos
  final double sensitivity;

  GyroscopeManager({this.sensitivity = 2.0}) {
    // Escuta eventos do giroscópio
    gyroscopeEvents.listen((GyroscopeEvent event) {
      // Calcula os movimentos ajustados pela sensibilidade
      final xMovement = event.x * sensitivity;
      final zMovement = event.z * sensitivity;

      // Adiciona os valores ao StreamController
      _gyroscopeController.add({'x': xMovement, 'z': zMovement});
    });
  }

  // Método para encerrar o StreamController (boa prática para evitar vazamento de memória)
  void dispose() {
    _gyroscopeController.close();
  }
}
