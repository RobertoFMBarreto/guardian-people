class DeviceData {
  final int dataUsage;
  final double temperature;
  final int battery;
  final double lat;
  final double lon;
  final double elevation;
  final double accuracy;
  final DateTime dateTime;

  const DeviceData({
    required this.dataUsage,
    required this.battery,
    required this.elevation,
    required this.temperature,
    required this.lat,
    required this.lon,
    required this.accuracy,
    required this.dateTime,
  });
}
