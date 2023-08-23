import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:sqflite/sqflite.dart';

Future<Fence> createFence(Fence fence) async {
  final db = await GuardianDatabase().database;
  await db.insert(
    tableFence,
    fence.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  return fence;
}

Future<Fence?> getFence(String fenceId) async {
  final db = await GuardianDatabase().database;
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
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableFence,
    where: '${FenceFields.uid} = ?',
    whereArgs: [uid],
  );
  List<Fence> fences = [];
  if (data.isNotEmpty) {
    fences.addAll(
      data.map(
        (e) {
          return Fence.fromJson(e);
        },
      ),
    );
  }
  return fences;
}

Future<List<Fence>> searchFences(String searchString) async {
  final db = await GuardianDatabase().database;
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