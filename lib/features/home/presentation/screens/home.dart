import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questfy_app_mobile/core/theme/app.colors.dart';

import 'package:questfy_app_mobile/shared/widgets/progress_card.dart';
import 'package:questfy_app_mobile/shared/widgets/status_header.dart';
import '../providers/user_provider.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final progress = userProvider.progress;

    if (progress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            StatusHeader(
              streak: progress.streakCount,
              shields: progress.shieldsAvailable,
            ),
            ProgressCard(
              level: progress.currentLevel,
              percent: progress.progressInLevel,
              xp: progress.xp % 100,
            ),
            // Aqui entrará a lista de missões em seguida...
            Expanded(
              child: _buildMissionList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Abrir modal de nova missão
        },
      ),
    );
  }

  Widget _buildMissionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Missões de Hoje", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          // Exemplo de Card de Missão (Placeholder)
          _MissionTile(title: "Arrumar a cama", xp: 5, isCompleted: false),
          _MissionTile(title: "Ler 10 páginas", xp: 15, isCompleted: true),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  final String title;
  final int xp;
  final bool isCompleted;

  const _MissionTile({required this.title, required this.xp, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text("+$xp XP", style: TextStyle(color: AppColors.accent.withValues(alpha:  0.8), fontSize: 12)),
        ],
      ),
    );
  }
}