import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/user.dart';
import 'package:guardian/models/db/operations/guardian_database.dart';

Future<User?> getProducer(String uid) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableUser,
    where: '${UserFields.uid} = ?',
    whereArgs: [uid],
  );

  if (data.isNotEmpty) {
    return User.fromJson(
      data.first,
    );
  }
  return null;
}

Future<List<User>> getProducersWithSearchAndDevicesAmount(String searchString) async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery(
    '''
      SELECT 
        $tableUser.${UserFields.uid}, 
        $tableUser.${UserFields.email}, 
        $tableUser.${UserFields.name}, 
        $tableUser.${UserFields.phone},
        IFNULL(A.amount, 0) AS devicesAmount
      FROM $tableUser 
      LEFT JOIN 
        (
          SELECT ${DeviceFields.uid}, COUNT(${DeviceFields.deviceId}) AS amount FROM $tableDevices 
          GROUP BY ${DeviceFields.uid}
        ) A ON A.${DeviceFields.uid} = $tableUser.${UserFields.uid}
      WHERE ${UserFields.isAdmin} = ? AND 
            ($tableUser.${UserFields.name} LIKE ? OR ${UserFields.email} LIKE ?)
    ''',
    [false, '%$searchString%', '%$searchString%'],
  );

  return data.map((e) => User.fromJson(e)).toList();
}
