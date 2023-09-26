import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

/// Method for creating an user [user] returning it as an [UserCompanion]
Future<UserCompanion> createUser(UserCompanion user) async {
  final db = Get.find<GuardianDb>();
  await db.into(db.user).insertOnConflictUpdate(user);

  return user;
}

/// Method for deleting an user [idUser]
Future<void> deleteUser(BigInt idUser) async {
  final db = Get.find<GuardianDb>();

  (db.delete(db.user)..where((tbl) => tbl.idUser.equals(idUser))).go();
}

/// Method to update an user [user] returning it as an [UserCompanion]
Future<UserCompanion> updateUser(UserCompanion user) async {
  final db = Get.find<GuardianDb>();
  db.update(db.user).replace(user);

  return user;
}

/// Method to get an user information [idUser]  as [UserData?]
Future<UserData?> getUser(BigInt idUser) async {
  final db = Get.find<GuardianDb>();
  final data =
      await (db.select(db.user)..where((tbl) => tbl.idUser.equals(idUser))).getSingleOrNull();

  return data;
}

/// Method to check if an user [idUser] is an admin [bool]
Future<bool> userIsAdmin(BigInt idUser) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.user)..where((tbl) => tbl.idUser.equals(idUser))).getSingle();

  return data.isSuperuser;
}
