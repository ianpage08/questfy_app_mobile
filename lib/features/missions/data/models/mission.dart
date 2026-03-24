import 'package:questfy_app_mobile/shared/helpers/json_parsing_helper.dart';


enum MissionType { infinite, daily, weekly, challenge }

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int xpReward;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? deadline;
  final DateTime? completedAt;

  Mission({
    required this.id,
    required this.title,
    this.description = '',
    this.type = MissionType.infinite,
    this.xpReward = 5,
    this.isCompleted = false,
    required this.createdAt,
    this.deadline,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'xpReward': xpReward,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: JsonParsingHelper.stringOrEmtpy(json['id']),
    title: JsonParsingHelper.requiredString(json, 'title'),
    description: JsonParsingHelper.stringOrEmtpy(json['description']),
    type: MissionType.values.byName(
      JsonParsingHelper.optionalString(json['type']) ?? 'infinite'
    ),
    xpReward: JsonParsingHelper.optionalInt(json['xpReward']) ?? 5,
    isCompleted: JsonParsingHelper.optionalBool(json['isCompleted']) ?? false,
    createdAt: JsonParsingHelper.requiredDate(json['createdAt'], key: 'createdAt'),
    deadline: json['deadline'] != null ? JsonParsingHelper.requiredDate(json['deadline']) : null,
    completedAt: json['completedAt'] != null ? JsonParsingHelper.requiredDate(json['completedAt']) : null,
  );

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    MissionType? type,
    int? xpReward,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? deadline,
    DateTime? completedAt,
  }) => Mission(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    type: type ?? this.type,
    xpReward: xpReward ?? this.xpReward,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    deadline: deadline ?? this.deadline,
    completedAt: completedAt ?? this.completedAt,
  );
}