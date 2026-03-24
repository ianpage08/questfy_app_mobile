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

  Future<void> loadMissions() async {
    _isLoading = true;
    notifyListeners();

    _missions = await _repository.getAllMissions();
    
    _isLoading = false;
    notifyListeners();
  }

  /// Concluir ou Desmarcar Missão
  Future<void> toggleMission(String missionId, UserProvider userProvider) async {
    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index == -1) return;

    final mission = _missions[index];
    final bool isNowCompleted = !mission.isCompleted;

    // 1. Feedback tátil ao tocar (Dopamina instantânea)
    HapticFeedback.mediumImpact(); 

    if (isNowCompleted) {
      // 2. Se está completando, usa o serviço de gamificação (Ganha XP)
      final updatedUser = await _gamificationService.completeMission(missionId);
      userProvider.updateFromProgress(updatedUser);
    } else {
      // 3. Se está desmarcando, apenas atualiza o repositório (Opcional: Tirar XP?)
      await _repository.updateMissionStatus(missionId, false);
    }

    // 4. Atualiza a lista local
    await loadMissions();
  }
  Future<void> addMission({
  required String title,
  required MissionType type,
  required int xp,
}) async {
  final newMission = Mission(
    id: const Uuid().v4(), // Gera um ID único
    title: title,
    type: type,
    xpReward: xp,
    createdAt: DateTime.now(),
    isCompleted: false,
  );

  await _repository.saveMission(newMission);
  await loadMissions(); // Recarrega a lista para a UI atualizar
  HapticFeedback.lightImpact(); 
}

  // Futuro: Método para adicionar nova missão
}