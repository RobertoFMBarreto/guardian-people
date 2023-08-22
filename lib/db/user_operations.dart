import 'package:guardian/db/guardian_database.dart';

import '../models/data_models/user.dart';

Future<User> createUser(User user) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.insert(tableUser, user.toJson());

  return user.copy(id: id);
}

Future<int> deleteUser(int id) async {
  final db = await GuardianDatabase.instance.database;

  return db.delete(
    tableUser,
    where: '${UserFields.id} = ?',
    whereArgs: [id],
  );
}

Future<User> updateUser(User user) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.update(
    tableUser,
    user.toJson(),
    where: '${UserFields.id} = ?',
    whereArgs: [user.id],
  );

  return user.copy(id: id);
}

Future<User?> getUser(String uid) async {
  final db = await GuardianDatabase.instance.database;
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
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableUser,
    where: '${UserFields.isAdmin} = ?',
    whereArgs: [false],
  );

  return data.map((e) => User.fromJson(e)).toList();
}

Future<bool> userIsAdmin(String uid) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableUser,
    where: '${UserFields.uid} = ?',
    whereArgs: [uid],
  );

  return (data.map((e) => User.fromJson(e)).toList()).first.isAdmin;
}
