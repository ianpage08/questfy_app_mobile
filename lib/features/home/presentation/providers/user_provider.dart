import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:questfy_app_mobile/features/profile/domain/services/gamification_service.dart';
import 'package:questfy_app_mobile/features/profile/presentation/data/models/user_progress.dart';
import 'package:questfy_app_mobile/features/profile/presentation/data/repositories/i_user_progress_repository.dart';

@injectable
class UserProvider extends ChangeNotifier {
  final GamificationService _gamificationService;
  final IUserProgressRepository repository;

  UserProgress? _progress;
  UserProgress? get progress => _progress;

  UserProvider(this._gamificationService, this.repository);

  /// Inicialização (Chamado no Main)
  Future<void> loadData() async {
    // Processa a streak logo ao abrir
    _progress = await _gamificationService.processDailyStreak();
    notifyListeners();
  }

  /// Quando o usuário clica no Checkbox da missão
  Future<void> completeMission(String missionId) async {
    _progress = await _gamificationService.completeMission(missionId);
    
    // Se a streak count for 0 e ele completou a primeira missão do dia,
    // poderíamos incrementar a streak aqui também.
    
    notifyListeners();
    // Aqui você pode disparar animações de XP ou Level Up na UI
  }
}