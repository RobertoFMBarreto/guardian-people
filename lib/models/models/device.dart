class Device {
  final int imei;
  final int dataUsage;
  final int battery;
  final double elevation;
  final double temperature;

  const Device({
    required this.imei,
    required this.dataUsage,
    required this.battery,
    required this.elevation,
    required this.temperature,
  });
}
