import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:questfy_app_mobile/core/theme/app.colors.dart';

class LevelUpOverlay extends StatelessWidget {
  final int newLevel;

  const LevelUpOverlay({super.key, required this.newLevel});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Efeito de desfoque no fundo
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),
          
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone Neon
                Icon(Icons.auto_awesome, color: AppColors.accent, size: 80),
                const SizedBox(height: 20),
                
                const Text(
                  "NOVO NÍVEL ALCANÇADO",
                  style: TextStyle(
                    color: AppColors.accent,
                    letterSpacing: 4,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Número do Nível Grande
                Text(
                  "$newLevel",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Botão Minimalista
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "CONTINUAR JORNADA",
                    style: TextStyle(color: Colors.white, fontSize: 12),
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