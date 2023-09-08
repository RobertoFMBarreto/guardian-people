import 'package:guardian/models/db/drift/database.dart';

class Device {
  final DeviceCompanion device;
  final List<DeviceLocationsCompanion> data;

  Device({
    required this.device,
    required this.data,
  });
}
