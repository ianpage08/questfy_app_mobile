import 'package:injectable/injectable.dart';
import 'package:questfy_app_mobile/features/missions/data/models/mission.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IMissionRepository {
  Future<void> saveMission(Mission mission);
}

@LazySingleton(as: IMissionRepository) // Registra como Singleton (instância única)
class MissionRepository implements IMissionRepository {
  final SharedPreferences prefs;

  // O Injectable vai passar o SharedPreferences aqui automaticamente
  MissionRepository(this.prefs);

  @override
  Future<void> saveMission(Mission mission) async {
    // Lógica usando _prefs e seu toJson()
  }
}