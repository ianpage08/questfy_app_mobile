import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/services.dart';
import 'package:questfy_app_mobile/features/missions/data/models/mission.dart';
import 'package:questfy_app_mobile/features/profile/presentation/data/models/user_progress.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/i_mission_repository.dart';
import '../../../profile/domain/services/gamification_service.dart';
import '../../../home/presentation/providers/user_provider.dart';

@injectable
class MissionProvider extends ChangeNotifier {
  final IMissionRepository _repository;
  final GamificationService _gamificationService;

  List<Mission> _missions = [];
  List<Mission> get missions => _missions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MissionProvider(this._repository, this._gamificationService);

  Future<void> loadMissions() async {
    _isLoading = true;
    notifyListeners();

    final allMissions = await _repository.getAllMissions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _missions = allMissions.map((m) {
      // REGRA DE OURO: Reset à meia-noite para Infinitas e Diárias
      if (m.isCompleted && m.lastCompletedAt != null) {
        final lastDate = DateTime(
          m.lastCompletedAt!.year,
          m.lastCompletedAt!.month,
          m.lastCompletedAt!.day,
        );

        if (today.isAfter(lastDate)) {
          // Se hoje é um novo dia, a missão volta a ficar aberta
          return m.copyWith(isCompleted: false);
        }
      }
      return m;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkAndResetMissions() async {
    final now = DateTime.now();
    bool hasChanges = false;
    final List<Mission> updatedList = [];

    for (var m in _missions) {
      var mission = m;

      // 1. Reset Diário (Infinitas)
      if (mission.type == MissionType.infinite && mission.isCompleted) {
        if (mission.completedAt != null &&
            mission.completedAt!.day != now.day) {
          mission = mission.copyWith(isCompleted: false, completedAt: null);
          hasChanges = true;
        }
      }

      // 2. Limpeza de Desafios Expirados (Se não concluídos e passou da data)
      if (mission.type == MissionType.challenge && mission.deadline != null) {
        if (now.isAfter(mission.deadline!) && !mission.isCompleted) {
          // Lógica opcional: Deletar ou marcar como falha
        }
      }

      updatedList.add(mission);
    }

    if (hasChanges) {
      _missions = updatedList;
      // Salvar lista no repo
      notifyListeners();
    }
  }

  /// Concluir ou Desmarcar Missão
  Future<void> toggleMission(
    String missionId,
    UserProvider userProvider,
  ) async {
    final index = _missions.indexWhere((m) => m.id == missionId);
    final mission = _missions[index];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // BLOQUEIO: Se for infinita/diária e já foi feita HOJE, não pode desmarcar
    if (mission.isCompleted && mission.lastCompletedAt != null) {
      final lastDate = DateTime(
        mission.lastCompletedAt!.year,
        mission.lastCompletedAt!.month,
        mission.lastCompletedAt!.day,
      );

      if (lastDate == today) {
        // Opcional: Mostrar um aviso que já foi concluída hoje
        HapticFeedback.vibrate();
        return;
      }
    }

    // Se estiver completando agora
    if (!mission.isCompleted) {
      final updatedUser = await _gamificationService.completeMission(missionId);
      userProvider.updateFromProgress(updatedUser);

      // Atualiza localmente com a data de conclusão
      _missions[index] = mission.copyWith(
        isCompleted: true,
        lastCompletedAt: now,
      );

      await _repository.saveMission(_missions[index]);

      // Regra de Auto-Exclusão para Diárias (Como você pediu antes)
      if (mission.type == MissionType.daily ||
          mission.type == MissionType.challenge) {
        await Future.delayed(const Duration(milliseconds: 800));
        await deleteMission(missionId);
      }
    }

    notifyListeners();
  }

  Future<void> deleteMission(String id) async {
    await _repository.deleteMission(id);
    await loadMissions();
  }

  Future<void> addMission({
    required String title,
    required String icon,
    required MissionType type,
    required int xp,
    DateTime? deadline,
  }) async {
    final newMission = Mission(
      id: const Uuid().v4(), // Gera um ID único
      title: title,
      type: type,
      icon: icon,
      xpReward: xp,
      createdAt: DateTime.now(),
      isCompleted: false,
      deadline: deadline,
    );

    await _repository.saveMission(newMission);
    await loadMissions(); // Recarrega a lista para a UI atualizar
    HapticFeedback.lightImpact();
  }

  // Futuro: Método para adicionar nova missão
}
