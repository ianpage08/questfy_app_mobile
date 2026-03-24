import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questfy_app_mobile/core/theme/app.colors.dart';
import 'package:questfy_app_mobile/features/missions/data/providers/mission_provider.dart';
import 'package:questfy_app_mobile/shared/widgets/progress_card.dart';
import 'package:questfy_app_mobile/shared/widgets/status_header.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escutando os providers
    final missionProvider = context.watch<MissionProvider>();
    final userProvider = context.watch<UserProvider>();
    final progress = userProvider.progress;

    if (progress == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com Foguinho e Escudo
            StatusHeader(
              streak: progress.streakCount,
              shields: progress.shieldsAvailable,
            ),

            // Card de Nível e XP
            ProgressCard(
              level: progress.currentLevel,
              percent: progress.progressInLevel,
              xp: progress.xp % 100,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Missões de Hoje",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Lista Dinâmica de Missões
            Expanded(child: _buildMissionList(missionProvider, userProvider)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          // TODO: Abrir BottomSheet de Nova Missão
        },
      ),
    );
  }

  Widget _buildMissionList(
    MissionProvider missionProvider,
    UserProvider userProvider,
  ) {
    final missions = missionProvider.missions;

    if (missionProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "Nada por aqui ainda.\nQue tal começar uma nova missão?",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return _MissionTile(
          title: mission.title,
          xp: mission.xpReward,
          isCompleted: mission.isCompleted,
          onTap: () {
            // Chama o provider para marcar/desmarcar
            missionProvider.toggleMission(mission.id, userProvider);
          },
        );
      },
    );
  }
}

class _MissionTile extends StatelessWidget {
  final String title;
  final int xp;
  final bool isCompleted;
  final VoidCallback onTap;

  const _MissionTile({
    required this.title,
    required this.xp,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.surface.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.accent.withValues(alpha: 0.2)
                : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icone de Check animado
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? AppColors.accent : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 15),

            // Título da Missão
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isCompleted
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: isCompleted ? FontWeight.normal : FontWeight.w500,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),

            // Badge de XP
            if (!isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "+$xp XP",
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
