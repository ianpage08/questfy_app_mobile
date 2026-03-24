import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:questfy_app_mobile/features/missions/data/models/mission.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'i_mission_repository.dart';

@LazySingleton(as: IMissionRepository)
class MissionRepositoryImpl implements IMissionRepository {
  final SharedPreferences _prefs;
  static const _key = 'missions_list';

  MissionRepositoryImpl(this._prefs);

  @override
  Future<List<Mission>> getAllMissions() async {
    final List<String>? missionsJson = _prefs.getStringList(_key);
    if (missionsJson == null) return [];

    return missionsJson
        .map((item) => Mission.fromJson(jsonDecode(item)))
        .toList();
  }

  @override
  Future<void> saveMission(Mission mission) async {
    final missions = await getAllMissions();
    
    // Se a missão já existe (edição), substitui. Senão, adiciona.
    final index = missions.indexWhere((m) => m.id == mission.id);
    if (index != -1) {
      missions[index] = mission;
    } else {
      missions.add(mission);
    }

    await _saveAll(missions);
  }

  @override
  Future<void> deleteMission(String id) async {
    final missions = await getAllMissions();
    missions.removeWhere((m) => m.id == id);
    await _saveAll(missions);
  }

  @override
  Future<void> updateMissionStatus(String id, bool isCompleted) async {
    final missions = await getAllMissions();
    final index = missions.indexWhere((m) => m.id == id);
    
    if (index != -1) {
      missions[index] = missions[index].copyWith(
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
      );
      await _saveAll(missions);
    }
  }

  // Helper privado para persistir a lista completa
  Future<void> _saveAll(List<Mission> missions) async {
    final List<String> jsonList = missions
        .map((m) => jsonEncode(m.toJson()))
        .toList();
    await _prefs.setStringList(_key, jsonList);
  }
}