import 'package:injectable/injectable.dart';
import 'package:questfy_app_mobile/features/profile/presentation/data/models/user_progress.dart';
import 'package:questfy_app_mobile/features/profile/presentation/data/repositories/i_user_progress_repository.dart';
import '../../../missions/data/repositories/i_mission_repository.dart';


@lazySingleton
class GamificationService {
  final IUserProgressRepository _progressRepository;
  final IMissionRepository _missionRepository;

  GamificationService(
    this._progressRepository,
    this._missionRepository,
  );

  /// Ação principal: Concluir uma missão e recompensar o usuário
  Future<UserProgress> completeMission(String missionId) async {
    // 1. Buscar a missão
    final missions = await _missionRepository.getAllMissions();
    final missionIndex = missions.indexWhere((m) => m.id == missionId);

    if (missionIndex == -1 || missions[missionIndex].isCompleted) {
      return await _progressRepository.getProgress();
    }

    final mission = missions[missionIndex];

    // 2. Marcar missão como concluída no repositório
    await _missionRepository.updateMissionStatus(missionId, true);

    // 3. Buscar progresso atual e atualizar XP
    final currentProgress = await _progressRepository.getProgress();
    
    // Calculamos o novo XP
    int newXp = currentProgress.xp + mission.xpReward;
    
    // 4. Lógica de Sequência (Streak)
    // Se for a primeira missão do dia, validamos a streak
    UserProgress updatedProgress = currentProgress.copyWith(
      xp: newXp,
    );

    // Salvar e retornar o novo estado
    await _progressRepository.saveProgress(updatedProgress);
    return updatedProgress;
  }

  /// Lógica de validação da Sequência (chamada ao abrir o app)
  Future<UserProgress> processDailyStreak() async {
    final progress = await _progressRepository.getProgress();
    final now = DateTime.now();
    final lastCheckIn = progress.lastCheckIn;

    // Diferença em dias (zerando as horas para comparar apenas a data)
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day);
    final difference = today.difference(lastDate).inDays;

    if (difference <= 0) {
      // Já abriu o app hoje ou check-in é futuro, não faz nada
      return progress;
    }

    if (difference == 1) {
      // Ontem ele fez check-in. A sequência continua, mas só aumenta 
      // quando ele completar a primeira missão do dia (ou apenas por abrir, você escolhe).
      // Por enquanto, vamos apenas atualizar a data do último acesso.
      final updated = progress.copyWith(lastCheckIn: now);
      await _progressRepository.saveProgress(updated);
      return updated;
    } 

    // Se chegou aqui, ele pulou um ou mais dias (difference > 1)
    if (progress.shieldsAvailable > 0) {
      // SALVO PELO ESCUDO! 🛡️
      final updated = progress.copyWith(
        shieldsAvailable: progress.shieldsAvailable - 1,
        lastCheckIn: now.subtract(const Duration(days: 0)), // Mantém a chama viva
      );
      await _progressRepository.saveProgress(updated);
      return updated;
    } else {
      // QUEBROU A SEQUÊNCIA 💔
      final updated = progress.copyWith(
        streakCount: 0,
        lastCheckIn: now,
      );
      await _progressRepository.saveProgress(updated);
      return updated;
    }
  }

  /// Ganhar um escudo (Pode ser por nível ou por compra com XP)
  Future<UserProgress> rewardShield() async {
    final progress = await _progressRepository.getProgress();
    final updated = progress.copyWith(
      shieldsAvailable: progress.shieldsAvailable + 1,
    );
    await _progressRepository.saveProgress(updated);
    return updated;
  }
}