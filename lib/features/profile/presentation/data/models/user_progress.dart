import 'package:questfy_app_mobile/shared/helpers/json_parsing_helper.dart';


class UserProgress {
  final int xp;
  final int streakCount;
  final int shieldsAvailable;
  final DateTime lastCheckIn;
  final List<String> unlockedMedals;

  UserProgress({
    required this.xp,
    required this.streakCount,
    required this.shieldsAvailable,
    required this.lastCheckIn,
    required this.unlockedMedals,
  });

  // Getters úteis para a UI
  int get currentLevel => (xp / 100).floor() + 1;
  double get progressInLevel => (xp % 100) / 100; // 0.0 a 1.0 para a barra

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'streakCount': streakCount,
    'shieldsAvailable': shieldsAvailable,
    'lastCheckIn': lastCheckIn.toIso8601String(),
    'unlockedMedals': unlockedMedals,
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    xp: JsonParsingHelper.optionalInt(json['xp']) ?? 0,
    streakCount: JsonParsingHelper.optionalInt(json['streakCount']) ?? 0,
    shieldsAvailable: JsonParsingHelper.optionalInt(json['shieldsAvailable']) ?? 0,
    lastCheckIn: JsonParsingHelper.requiredDate(json['lastCheckIn'], key: 'lastCheckIn'),
    unlockedMedals: JsonParsingHelper.stringListOrEmpty(json['unlockedMedals']),
  );

  UserProgress copyWith({
    int? xp,
    int? streakCount,
    int? shieldsAvailable,
    DateTime? lastCheckIn,
    List<String>? unlockedMedals,
  }) => UserProgress(
    xp: xp ?? this.xp,
    streakCount: streakCount ?? this.streakCount,
    shieldsAvailable: shieldsAvailable ?? this.shieldsAvailable,
    lastCheckIn: lastCheckIn ?? this.lastCheckIn,
    unlockedMedals: unlockedMedals ?? this.unlockedMedals,
  );
}