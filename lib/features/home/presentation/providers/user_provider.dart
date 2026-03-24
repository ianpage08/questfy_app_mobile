import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:questfy_app_mobile/features/profile/domain/services/gamification_service.dart';
import 'package:questfy_app_mobile/features/profile/presentation/data/models/user_progress.dart';
import 'package:questfy_app_mobile/features/profile/presentation/data/repositories/i_user_progress_repository.dart';

@injectable
class UserProvider extends ChangeNotifier {
  final GamificationService _gamificationService;
  final IUserProgressRepository repository;

  final _levelUpController = StreamController<int>.broadcast();
  Stream<int> get onLevelUp => _levelUpController.stream;

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
    if (_progress == null) return;

    final oldLevel = _progress!.currentLevel; // Guarda o nível antigo

    // Processa a conclusão
    _progress = await _gamificationService.completeMission(missionId);

    // Verifica se subiu de nível
    if (_progress!.currentLevel > oldLevel) {
      _levelUpController.add(_progress!.currentLevel); // Dispara o evento
    }

    notifyListeners();
  }

  void updateFromProgress(UserProgress updatedProgress) {
    _progress = updatedProgress;
    notifyListeners();
  }

  @override
  void dispose() {
    _levelUpController.close();
    super.dispose();
  }
}
