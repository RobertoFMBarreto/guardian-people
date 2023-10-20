import 'dart:convert';
import 'dart:math';

import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:drift/drift.dart' as drift;

/// Method that allows to read json [body] and parse to an [AnimalCompanion] inserting it on the database in the process
Future<void> animalsFromJson(String body) async {
  final data = jsonDecode(body);
  for (var dt in data) {
    await createAnimal(AnimalCompanion(
      isActive: drift.Value(dt['animal_is_active'] == true),
      animalName: drift.Value(dt['animal_name']),
      idUser: drift.Value(dt['id_user']),
      animalColor: drift.Value(dt['animal_color']),
      animalIdentification: drift.Value(dt['animal_identification']),
      idAnimal: drift.Value(dt['id_animal']),
    ));
    if (dt['last_device_data'] != null) {
      await animalDataFromJson(dt['last_device_data'], dt['id_animal']);
    }
  }
}

/// Method that allows to read json [data] that contains a device location data and parses it to an [AnimalLocationsCompanion] inserting it on the database in the process
Future<void> animalDataFromJson(Map<String, dynamic> data, String idAnimal) async {
  List<String> states = ['Ruminar', 'Comer', 'Andar', 'Correr', 'Parada'];
  await createAnimalData(
    AnimalLocationsCompanion(
      dataUsage: drift.Value(Random().nextInt(10)),
      date: drift.Value(DateTime.parse(data['date'])),
      animalDataId: drift.Value(data['id_data']),
      idAnimal: drift.Value(idAnimal),
      state: drift.Value(states[Random().nextInt(states.length)]),
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
      temperature: data['skinTemperature'] != null
          ? drift.Value(double.tryParse(data['skinTemperature']))
          : const drift.Value.absent(),
    ),
  );
}
