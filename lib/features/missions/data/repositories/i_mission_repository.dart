import 'package:questfy_app_mobile/features/missions/data/models/mission.dart';


abstract class IMissionRepository {
  Future<List<Mission>> getAllMissions();
  Future<void> saveMission(Mission mission);
  Future<void> deleteMission(String id);
  Future<void> updateMissionStatus(String id, bool isCompleted);
}