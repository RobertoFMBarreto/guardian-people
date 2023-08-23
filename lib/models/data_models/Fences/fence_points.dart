const String tableFencePoints = 'fence_points';

class FencePointsFields {
  static const String fencePointsId = 'fence_points_id';
  static const String fenceId = 'fence_id';
  static const String lat = 'lat';
  static const String lon = 'lon';
}

class FencePoints {
  final String fenceId;
  final double lat;
  final double lon;
  FencePoints({
    required this.fenceId,
    required this.lat,
    required this.lon,
  });

  FencePoints copy({
    String? fenceId,
    double? lat,
    double? lon,
  }) =>
      FencePoints(
        fenceId: fenceId ?? this.fenceId,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );

  Map<String, Object?> toJson() => {
        FencePointsFields.fenceId: fenceId,
        FencePointsFields.lat: lat,
        FencePointsFields.lon: lon,
      };

  static FencePoints fromJson(Map<String, Object?> json) => FencePoints(
        fenceId: json[FencePointsFields.fenceId] as String,
        lat: json[FencePointsFields.lat] as double,
        lon: json[FencePointsFields.lon] as double,
      );
}
