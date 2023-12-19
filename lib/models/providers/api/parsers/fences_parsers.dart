import 'dart:convert';

import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:drift/drift.dart' as drift;

/// Method that parsers json fence from [body] to a [FenceCompanion] inserting it in the database
///
/// This method also parses the fence points [fencePointFromJson] and animals [fenceAnimalFromJson] inserting on the database
Future<void> fencesFromJson(String body) async {
  final data = jsonDecode(body);

  for (var dt in data) {
    await createFence(FenceCompanion(
      idFence: drift.Value(dt['idFence']),
      idUser: drift.Value(dt['idUser']),
      name: drift.Value(dt['fenceName']),
      color: drift.Value(dt['fenceColor']),
      isStayInside: drift.Value(dt['isStayInside']),
    ));
    for (var point in dt['fencePoints']) {
      await fencePointFromJson(point, dt['idFence']);
    }
    for (var animal in dt['fenceAnimals']) {
      await fenceAnimalFromJson(animal, dt['idFence']);
    }
  }
}

/// Method that parses fence point data [data] from the fence [idFence] and inserts it on database
Future<void> fencePointFromJson(Map<dynamic, dynamic> data, String idFence) async {
  await createFencePoint(
    FencePointsCompanion(
      idFence: drift.Value(idFence),
      idFencePoint: drift.Value(data['idFencePoint']),
      isCenter: drift.Value(data['isCenter']),
      lat: drift.Value(double.parse(data['lat'])),
      lon: drift.Value(double.parse(data['lon'])),
    ),
  );
}

/// Method that parses animal data [data] from the fence [idFence] and inserts it on database
Future<void> fenceAnimalFromJson(Map<dynamic, dynamic> data, String idFence) async {
  await createFenceAnimal(
    FenceAnimalsCompanion(
      idAnimal: drift.Value(data['idAnimal']),
      idFence: drift.Value(idFence),
    ),
  );
}
