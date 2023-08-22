import 'package:guardian/db/fence_operations.dart';
import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/data_models/Fences/fence_devices.dart';

Future<List<Fence>> getDeviceFences(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableFenceDevices,
    where: '${FenceDevicesFields.deviceId} = ?',
    whereArgs: [deviceId],
  );

  List<Fence> fences = [];

  if (data.isNotEmpty) {
    print('GetDevices: $data');
    fences.addAll(
      data.map(
        (e) async => await getFence(FenceDevices.fromJson(e).deviceId),
      ) as Iterable<Fence>,
    );
  }
  return fences;
}
