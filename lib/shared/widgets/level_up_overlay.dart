import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:questfy_app_mobile/core/theme/app.colors.dart';

class LevelUpOverlay extends StatelessWidget {
  final int newLevel;

  const LevelUpOverlay({super.key, required this.newLevel});

  // Lógica de títulos por faixa de nível
  String _getLevelTitle(int level) {
    if (level >= 20) return "MESTRE DA ROTINA";
    if (level >= 15) return "LENDÁRIO";
    if (level >= 10) return "INABALÁVEL";
    if (level >= 5) return "FOCADO";
    return "INICIANTE";
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Glassmorphism background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withValues(alpha: 0.8)),
          ),
          
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ANIMAÇÃO LOTTIE (Certifique-se de adicionar o arquivo no pubspec.yaml)
                Lottie.asset(
                  'assets/animations/level_up.json', // Nome do seu arquivo JSON
                  width: 250,
                  repeat: false,
                ),

                Text(
                  "LEVEL UP",
                  style: TextStyle(
                    color: AppColors.accent,
                    letterSpacing: 6,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                
                Text(
                  "$newLevel",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),

                Text(
                  _getLevelTitle(newLevel),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const SizedBox(height: 50),
                
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    "CONTINUAR",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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