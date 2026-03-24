import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:questfy_app_mobile/features/profile/presentation/data/models/user_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'i_user_progress_repository.dart';

@LazySingleton(as: IUserProgressRepository)
class UserProgressRepositoryImpl implements IUserProgressRepository {
  final SharedPreferences _prefs;
  static const _key = 'user_progress_data';

  UserProgressRepositoryImpl(this._prefs);

  @override
  Future<UserProgress> getProgress() async {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) {
      // Estado inicial do novo usuário
      return UserProgress(
        xp: 0,
        streakCount: 0,
        shieldsAvailable: 1, // Presente de boas-vindas
        lastCheckIn: DateTime.now().subtract(const Duration(days: 2)),
        unlockedMedals: [],
      );
    }
    return UserProgress.fromJson(jsonDecode(jsonString));
  }

  @override
  Future<void> saveProgress(UserProgress progress) async {
    await _prefs.setString(_key, jsonEncode(progress.toJson()));
  }
}