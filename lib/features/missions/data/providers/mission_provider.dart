import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/services.dart';
import 'package:questfy_app_mobile/features/missions/data/models/mission.dart';
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

  /// Carrega as missões e reseta as diárias/infinitas se for um novo dia
  Future<void> loadMissions() async {
    _isLoading = true;
    notifyListeners();

    final allMissions = await _repository.getAllMissions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _missions = allMissions.map((m) {
      // RESET DIÁRIO: Se a missão foi completada em um dia anterior, reseta o status
      if (m.isCompleted && m.lastCompletedAt != null) {
        final lastDate = DateTime(
          m.lastCompletedAt!.year,
          m.lastCompletedAt!.month,
          m.lastCompletedAt!.day,
        );

        if (today.isAfter(lastDate)) {
          return m.copyWith(isCompleted: false);
        }
      }
      return m;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Alterna o status da missão com regras de gamificação
  Future<void> toggleMission(String missionId, UserProvider userProvider) async {
    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index == -1) return;

    final mission = _missions[index];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. BLOQUEIO DE SEGURANÇA: Se já foi feita HOJE, não pode desmarcar (evita farm de XP)
    if (mission.isCompleted && mission.lastCompletedAt != null) {
      final lastDate = DateTime(mission.lastCompletedAt!.year, mission.lastCompletedAt!.month, mission.lastCompletedAt!.day);
      if (lastDate == today) {
        HapticFeedback.heavyImpact(); // Vibração de "erro/bloqueio"
        return;
      }
    }

    // 2. FEEDBACK TÁTIL INICIAL
    HapticFeedback.mediumImpact();

    // 3. SE ESTÁ COMPLETANDO AGORA
    if (!mission.isCompleted) {
      // Chama o serviço de gamificação (Ganha XP e verifica Level Up)
      final updatedUser = await _gamificationService.completeMission(missionId);
      userProvider.updateFromProgress(updatedUser);

      // Atualiza localmente
      final updatedMission = mission.copyWith(
        isCompleted: true,
        lastCompletedAt: now,
      );
      
      _missions[index] = updatedMission;
      await _repository.saveMission(updatedMission);

      // 4. AUTO-EXCLUSÃO (Diárias e Desafios somem após completar)
      if (mission.type == MissionType.daily || mission.type == MissionType.challenge) {
        await Future.delayed(const Duration(milliseconds: 800)); // Delay para o usuário ver o check
        await deleteMission(missionId);
      }
    } else {
      // Caso de desmarcar (Só permitido se não for do mesmo dia ou regras específicas)
      final updatedUser = await _gamificationService.undoMissionCompletion(missionId);
      userProvider.updateFromProgress(updatedUser);
      
      final updatedMission = mission.copyWith(isCompleted: false);
      _missions[index] = updatedMission;
      await _repository.saveMission(updatedMission);
    }

    notifyListeners();
  }

  Future<void> deleteMission(String id) async {
    await _repository.deleteMission(id);
    // Em vez de reload total, removemos da lista local para performance
    _missions.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> addMission({
    required String title,
    required String icon,
    required MissionType type,
    required int xp,
    DateTime? deadline,
  }) async {
    final newMission = Mission(
      id: const Uuid().v4(),
      title: title,
      type: type,
      icon: icon,
      xpReward: xp,
      createdAt: DateTime.now(),
      isCompleted: false,
      deadline: deadline,
    );

    await _repository.saveMission(newMission);
    await loadMissions();
    HapticFeedback.vibrate();
  }
}