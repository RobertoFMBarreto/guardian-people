import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence.dart';
import 'package:guardian/models/db/drift/tables/Device/device.dart';

class FenceDevices extends Table {
  TextColumn get fenceId => text().references(Fence, #fenceId)();
  TextColumn get deviceId => text().references(Device, #deviceId)();

  @override
  Set<Column> get primaryKey => {fenceId, deviceId};
}
