const String tableFencePoints = 'fence_points';

class FencePointFields {
  static const String fencePointsId = 'fence_points_id';
  static const String fenceId = 'fence_id';
  static const String lat = 'lat';
  static const String lon = 'lon';
}

class FencePoint {
  final String fenceId;
  final double lat;
  final double lon;
  FencePoint({
    required this.fenceId,
    required this.lat,
    required this.lon,
  });

  FencePoint copy({
    String? fenceId,
    double? lat,
    double? lon,
  }) =>
      FencePoint(
        fenceId: fenceId ?? this.fenceId,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );

  Map<String, Object?> toJson() => {
        FencePointFields.fenceId: fenceId,
        FencePointFields.lat: lat,
        FencePointFields.lon: lon,
      };

  static FencePoint fromJson(Map<String, Object?> json) => FencePoint(
        fenceId: json[FencePointFields.fenceId] as String,
        lat: json[FencePointFields.lat] as double,
        lon: json[FencePointFields.lon] as double,
      );
}
