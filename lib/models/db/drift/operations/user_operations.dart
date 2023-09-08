import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

Future<UserCompanion> createUser(UserCompanion user) async {
  final db = Get.find<GuardianDb>();
  await db.into(db.user).insertOnConflictUpdate(user);

  return user;
}

Future<void> deleteUser(String uid) async {
  final db = Get.find<GuardianDb>();

  (db.delete(db.user)..where((tbl) => tbl.uid.equals(uid))).go();
}

Future<UserCompanion> updateUser(UserCompanion user) async {
  final db = Get.find<GuardianDb>();
  db.update(db.user).replace(user);

  return user;
}

Future<UserData?> getUser(String uid) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.user)..where((tbl) => tbl.uid.equals(uid))).getSingleOrNull();

  return data;
}

Future<bool> userIsAdmin(String uid) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.user)..where((tbl) => tbl.uid.equals(uid))).getSingle();

  return data.isAdmin;
}
