import 'package:questfy_app_mobile/features/profile/presentation/data/models/user_progress.dart';



abstract class IUserProgressRepository {
  Future<UserProgress> getProgress();
  Future<void> saveProgress(UserProgress progress);
}