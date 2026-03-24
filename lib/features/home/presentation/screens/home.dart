import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:questfy_app_mobile/core/theme/app.colors.dart';
import 'package:questfy_app_mobile/features/missions/data/models/mission.dart';
import 'package:questfy_app_mobile/features/missions/data/providers/mission_provider.dart';
import 'package:questfy_app_mobile/features/missions/presentation/widgets/add_mission_bottom_sheet.dart';
import 'package:questfy_app_mobile/shared/widgets/progress_card.dart';
import 'package:questfy_app_mobile/shared/widgets/status_header.dart';
import 'package:questfy_app_mobile/shared/widgets/level_up_overlay.dart'; // Importe o overlay criado
import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _levelUpSubscription;

  @override
  void initState() {
    super.initState();
    // Escuta o evento de Level Up assim que a tela inicia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _levelUpSubscription = context.read<UserProvider>().onLevelUp.listen((
        newLevel,
      ) {
        _showLevelUpOverlay(newLevel);
      });
    });
  }

  @override
  void dispose() {
    _levelUpSubscription?.cancel();
    super.dispose();
  }

  // Função para mostrar o Overlay de Level Up
  void _showLevelUpOverlay(int level) {
    HapticFeedback.vibrate();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => LevelUpOverlay(newLevel: level),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  // Função para confirmar exclusão
  Future<bool> _showConfirmDelete() async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Excluir Missão?",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            content: const Text(
              "Essa ação removerá a missão permanentemente.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Excluir",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
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
        child: RefreshIndicator(
          onRefresh: () => missionProvider.loadMissions(),
          backgroundColor: AppColors.surface,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusHeader(
                      streak: progress.streakCount,
                      shields: progress.shieldsAvailable,
                    ),
                    ProgressCard(
                      level: progress.currentLevel,
                      percent: progress.progressInLevel,
                      xp: progress
                          .xpProgressLabel, // Usando o label que criamos no model
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
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
                  ],
                ),
              ),
              _buildMissionList(missionProvider, userProvider),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () => _showAddMission(context),
      ),
    );
  }

  void _showAddMission(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMissionBottomSheet(),
    );
  }

  Widget _buildMissionList(
    MissionProvider missionProvider,
    UserProvider userProvider,
  ) {
    final missions = missionProvider.missions;

    if (missions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            "Nenhuma missão por aqui.",
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final mission = missions[index];
          return Dismissible(
            key: Key(mission.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _showConfirmDelete(),
            onDismissed: (_) => missionProvider.deleteMission(mission.id),
            background: _buildDismissibleBackground(),
            child: _MissionTile(
              mission: mission,
              onTap: () =>
                  missionProvider.toggleMission(mission.id, userProvider),
              onDelete: () async {
                if (await _showConfirmDelete())
                  missionProvider.deleteMission(mission.id);
              },
            ),
          );
        }, childCount: missions.length),
      ),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
    );
  }
}

class _MissionTile extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MissionTile({
    required this.mission,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDoneToday =
        mission.isCompleted && mission.lastCompletedAt?.day == now.day;
    bool isWeeklyDone =
        mission.type == MissionType.weekly && mission.isCompleted;

    return GestureDetector(
      onTap: isDoneToday ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: mission.isCompleted
              ? AppColors.surface.withValues(alpha: 0.4)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mission.isCompleted
                ? AppColors.accent.withValues(alpha: 0.05)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Text(mission.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: TextStyle(
                      color: isDoneToday
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: mission.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isDoneToday && mission.type == MissionType.infinite)
                    const Text(
                      "Concluída! Disponível novamente amanhã.",
                      style: TextStyle(color: AppColors.accent, fontSize: 10),
                    ),
                  if (isWeeklyDone)
                    const Text(
                      "Renova na próxima segunda-feira",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.more_horiz,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            Icon(
              mission.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: mission.isCompleted
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
