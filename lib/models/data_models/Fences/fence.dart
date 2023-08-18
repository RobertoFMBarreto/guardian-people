const String tableFence = 'devices';

class FenceFields {
  static const String id = '_id';
  static const String fenceId = 'fence_id';
  static const String name = 'name';
  static const String color = 'color';
}

class Fence {
  final int? id;
  final String fenceId;
  final String name;
  String color;
  Fence({
    this.id,
    required this.fenceId,
    required this.name,
    required this.color,
  });

  Fence copy({
    int? id,
    String? fenceId,
    String? name,
    String? color,
  }) =>
      Fence(
        id: id ?? this.id,
        fenceId: fenceId ?? this.fenceId,
        name: name ?? this.name,
        color: color ?? this.color,
      );

  Map<String, Object?> toJson() => {
        FenceFields.id: id,
        FenceFields.fenceId: fenceId,
        FenceFields.color: color,
        FenceFields.name: name,
      };

  static Fence fromJson(Map<String, Object?> json) => Fence(
        id: json[FenceFields.id] as int,
        fenceId: json[FenceFields.fenceId] as String,
        color: json[FenceFields.color] as String,
        name: json[FenceFields.name] as String,
      );
}
