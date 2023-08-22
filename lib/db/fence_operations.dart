import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';

Future<Fence?> getFence(String fenceId) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableFence,
    where: '${FenceFields.fenceId} = ?',
    whereArgs: [fenceId],
  );

  if (data.isNotEmpty) {
    return Fence.fromJson(data.first);
  }

  return null;
}

Future<List<Fence>> getUserFences(String uid) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableFence,
    where: '${FenceFields.uid} = ?',
    whereArgs: [uid],
  );

  List<Fence> fences = [];
  if (data.isNotEmpty) {
    fences.addAll(
      data.map((e) => Fence.fromJson(e)).toList(),
    );
  }

  return fences;
}

Future<List<Fence>> searchFences(String searchString) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableFence,
    where: '${FenceFields.name} LIKE ?',
    whereArgs: ['%$searchString%'],
  );

  List<Fence> fences = [];
  if (data.isNotEmpty) {
    fences.addAll(
      data.map((e) => Fence.fromJson(e)).toList(),
    );
  }

  return fences;
}
