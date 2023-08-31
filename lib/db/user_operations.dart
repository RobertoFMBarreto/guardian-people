import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:sqflite/sqflite.dart';

import '../models/data_models/user.dart';

Future<User> createUser(User user) async {
  final db = await GuardianDatabase().database;
  final id = await db.insert(
    tableUser,
    user.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  return user.copy(id: id);
}

Future<int> deleteUser(int id) async {
  final db = await GuardianDatabase().database;

  return db.delete(
    tableUser,
    where: '${UserFields.id} = ?',
    whereArgs: [id],
  );
}

Future<User> updateUser(User user) async {
  final db = await GuardianDatabase().database;
  final id = await db.update(
    tableUser,
    user.toJson(),
    where: '${UserFields.id} = ?',
    whereArgs: [user.id],
  );

  return user.copy(id: id);
}

Future<User?> getUser(String uid) async {
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

Future<List<User>> getProducers() async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableUser,
    where: '${UserFields.isAdmin} = ?',
    whereArgs: [false],
  );

  return data.map((e) => User.fromJson(e)).toList();
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

Future<bool> userIsAdmin(String uid) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableUser,
    where: '${UserFields.uid} = ?',
    whereArgs: [uid],
  );

  return (data.map((e) => User.fromJson(e)).toList()).first.isAdmin;
}
