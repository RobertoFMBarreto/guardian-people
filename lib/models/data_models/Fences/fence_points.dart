const String tableFencePoints = 'fence_devices';

class FencePointsFields {
  static const String id = '_id';
  static const String fenceId = 'fence_id';
  static const String lat = 'lat';
  static const String lon = 'lon';
}

class FencePoints {
  final int? id;
  final String fenceId;
  final double lat;
  final double lon;
  FencePoints({
    required this.id,
    required this.fenceId,
    required this.lat,
    required this.lon,
  });

  FencePoints copy({
    int? id,
    String? fenceId,
    double? lat,
    double? lon,
  }) =>
      FencePoints(
        id: id ?? this.id,
        fenceId: fenceId ?? this.fenceId,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );

  Map<String, Object?> toJson() => {
        FencePointsFields.id: id,
        FencePointsFields.fenceId: fenceId,
        FencePointsFields.lat: lat,
        FencePointsFields.lon: lon,
      };

  static FencePoints fromJson(Map<String, Object?> json) => FencePoints(
        id: json[FencePointsFields.id] as int,
        fenceId: json[FencePointsFields.fenceId] as String,
        lat: json[FencePointsFields.lat] as double,
        lon: json[FencePointsFields.lon] as double,
      );
}
