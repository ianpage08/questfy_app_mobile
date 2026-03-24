import 'package:questfy_app_mobile/shared/helpers/json_parsing_helper.dart';


enum FinanceType { income, expense }

class FinanceEntry {
  final String id;
  final String description;
  final double value;
  final FinanceType type;
  final String category;
  final DateTime date;

  FinanceEntry({
    required this.id,
    required this.description,
    required this.value,
    required this.type,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'value': value,
    'type': type.name,
    'category': category,
    'date': date.toIso8601String(),
  };

  factory FinanceEntry.fromJson(Map<String, dynamic> json) => FinanceEntry(
    id: JsonParsingHelper.stringOrEmtpy(json['id']),
    description: JsonParsingHelper.requiredString(json, 'description'),
    value: JsonParsingHelper.requiredDouble(json, 'value'),
    type: FinanceType.values.byName(
      JsonParsingHelper.optionalString(json['type']) ?? 'expense'
    ),
    category: JsonParsingHelper.optionalString(json['category']) ?? 'Geral',
    date: JsonParsingHelper.requiredDate(json['date'], key: 'date'),
  );

  FinanceEntry copyWith({
    String? id,
    String? description,
    double? value,
    FinanceType? type,
    String? category,
    DateTime? date,
  }) => FinanceEntry(
    id: id ?? this.id,
    description: description ?? this.description,
    value: value ?? this.value,
    type: type ?? this.type,
    category: category ?? this.category,
    date: date ?? this.date,
  );
}