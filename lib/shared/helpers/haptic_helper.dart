import 'package:flutter/services.dart';

class HapticHelper {
  // Ao marcar uma missão (Leve e rápido)
  static void success() => HapticFeedback.mediumImpact();

  // Ao subir de nível (Vibração dupla/forte)
  static void levelUp() async {
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.vibrate();
  }

  // Erro ou bloqueio (Vibração pesada única)
  static void error() => HapticFeedback.heavyImpact();
}