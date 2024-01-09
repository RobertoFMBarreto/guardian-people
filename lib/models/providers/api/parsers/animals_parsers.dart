import 'dart:convert';

import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:drift/drift.dart' as drift;

/// Method that allows to read json [body] and parse to an [AnimalCompanion] inserting it on the database in the process
Future<void> animalsFromJson(String body, {bool showLog = false}) async {
  final data = jsonDecode(body);
  for (var dt in data) {
    await createAnimal(
      AnimalCompanion(
        isActive: drift.Value(dt['isActive'] == true),
        animalName: drift.Value(dt['animalName']),
        idUser: drift.Value(dt['idUser']),
        animalColor: drift.Value(dt['animalColor']),
        animalIdentification: drift.Value(dt['animalIdentification']),
        idAnimal: drift.Value(dt['idAnimal']),
      ),
    );

    if (dt['locationData'] != null) {
      for (var location in dt['locationData']) {
        await animalDataFromJson(location, dt['idAnimal'], showLog: showLog);
      }
    }
  }
}

/// Method that allows to read json [data] that contains a device location data and parses it to an [AnimalLocationsCompanion] inserting it on the database in the process
Future<AnimalLocationsCompanion> animalDataFromJson(Map<dynamic, dynamic> data, String idAnimal,
    {bool showLog = false}) async {
  return await deleteAnimalData(data['id_data']).then(
    (_) async => await createAnimalData(
      AnimalLocationsCompanion(
        date: drift.Value(DateTime.parse(data['date'])),
        animalDataId: drift.Value(data['id_data']),
        idAnimal: drift.Value(idAnimal),
        state: data['activity'] != null
            ? drift.Value(data['activity'])
            : data['state'] != null
                ? drift.Value(data['state'])
                : const drift.Value.absent(),
        accuracy: data['accuracy'] != null
            ? drift.Value(double.tryParse(data['accuracy']))
            : const drift.Value.absent(),
        battery: data['battery'] != null
            ? drift.Value(int.tryParse(data['battery']))
            : const drift.Value.absent(),
        elevation: data['altitude'] != null
            ? drift.Value(double.tryParse(data['altitude']))
            : const drift.Value.absent(),
        lat: data['lat'] != null
            ? drift.Value(double.tryParse(data['lat']))
            : const drift.Value.absent(),
        lon: data['lon'] != null
            ? drift.Value(double.tryParse(data['lon']))
            : const drift.Value.absent(),
        temperature: data['skintemperature'] != null
            ? drift.Value(double.tryParse(data['skintemperature']))
            : const drift.Value.absent(),
      ),
    ),
  );
}

/// Method that allows to read json [data] that contains a device location data and parses it to an [AnimalLocationsCompanion] inserting it on the database in the process
Future<void> animalActivityFromJson(Map<dynamic, dynamic> data, String idAnimal) async {
  // await deleteAnimalActivity(data['id_data']).then(
  //   (_) async =>
  await createAnimalActivity(
    AnimalActivityCompanion(
      activityDate: drift.Value(DateTime.parse(data['read_date'])),
      animalDataActivityId: drift.Value(data['id_data']),
      idAnimalActivity: drift.Value(idAnimal),
      activity: data['sensor_data'] != null
          ? drift.Value(data['sensor_data'])
          : const drift.Value.absent(),
    ),
  );
  // );
}
