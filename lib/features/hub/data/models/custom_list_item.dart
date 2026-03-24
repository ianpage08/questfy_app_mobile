import 'package:questfy_app_mobile/shared/helpers/json_parsing_helper.dart';


class CustomListItem {
  final String id;
  final String label;
  final bool isDone;

  CustomListItem({required this.id, required this.label, this.isDone = false});

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'isDone': isDone};

  factory CustomListItem.fromJson(Map<String, dynamic> json) => CustomListItem(
    id: JsonParsingHelper.stringOrEmtpy(json['id']),
    label: JsonParsingHelper.stringOrEmtpy(json['label']),
    isDone: JsonParsingHelper.optionalBool(json['isDone']) ?? false,
  );
}

class CustomList {
  final String id;
  final String title;
  final String icon;
  final List<CustomListItem> items;

  CustomList({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': icon,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory CustomList.fromJson(Map<String, dynamic> json) => CustomList(
    id: JsonParsingHelper.stringOrEmtpy(json['id']),
    title: JsonParsingHelper.requiredString(json, 'title'),
    icon: JsonParsingHelper.optionalString(json['icon']) ?? 'list',
    items: (json['items'] as List<dynamic>?)
            ?.map((e) => CustomListItem.fromJson(e))
            .toList() ?? [],
  );

  CustomList copyWith({
    String? id,
    String? title,
    String? icon,
    List<CustomListItem>? items,
  }) => CustomList(
    id: id ?? this.id,
    title: title ?? this.title,
    icon: icon ?? this.icon,
    items: items ?? this.items,
  );
}