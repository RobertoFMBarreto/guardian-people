import 'dart:convert';
import 'dart:math';

import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/device_data_operations.dart';
import 'package:guardian/models/db/drift/operations/device_operations.dart';
import 'package:drift/drift.dart' as drift;

Future<void> animalsFromAnimalWithLastData(String body) async {
  final data = jsonDecode(body);
  List<String> states = ['Ruminar', 'Comer', 'Andar', 'Correr', 'Parada'];
  for (var dt in data) {
    await createDevice(DeviceCompanion(
      deviceName: drift.Value(dt['device_name']),
      idDevice: drift.Value(BigInt.from(int.parse(dt['id_device']))),
      isActive: drift.Value(dt['is_active'] == true),
    ));
    await createAnimal(AnimalCompanion(
      idDevice: drift.Value(BigInt.from(int.parse(dt['id_device']))),
      isActive: drift.Value(dt['animal_is_active'] == true),
      animalName: drift.Value(dt['animal_name']),
      idUser: drift.Value(BigInt.from(int.parse(dt['id_user']))),
      animalColor: drift.Value(dt['animal_color']),
      animalIdentification: drift.Value(dt['animal_identification']),
      idAnimal: drift.Value(BigInt.from(int.parse(dt['id_animal']))),
    ));
    if (dt['last_device_data'] != null) {
      await createDeviceData(
        DeviceLocationsCompanion(
          accuracy: dt['last_device_data']['accuracy'] != null
              ? drift.Value(double.tryParse(dt['last_device_data']['accuracy']))
              : const drift.Value.absent(),
          battery: dt['last_device_data']['battery'] != null
              ? drift.Value(int.tryParse(dt['last_device_data']['battery']))
              : const drift.Value.absent(),
          dataUsage: drift.Value(Random().nextInt(10)),
          date: drift.Value(DateTime.parse(dt['last_device_data']['date'])),
          deviceDataId: drift.Value(BigInt.from(int.parse(dt['last_device_data']['id_data']))),
          idDevice: drift.Value(BigInt.from(int.parse(dt['id_device']))),
          elevation: dt['last_device_data']['altitude'] != null
              ? drift.Value(double.tryParse(dt['last_device_data']['altitude']))
              : const drift.Value.absent(),
          lat: dt['last_device_data']['lat'] != null
              ? drift.Value(double.tryParse(dt['last_device_data']['lat']))
              : const drift.Value.absent(),
          lon: dt['last_device_data']['lon'] != null
              ? drift.Value(double.tryParse(dt['last_device_data']['lon']))
              : const drift.Value.absent(),
          state: drift.Value(states[Random().nextInt(states.length)]),
          temperature: dt['last_device_data']['skinTemperature'] != null
              ? drift.Value(double.tryParse(dt['last_device_data']['skinTemperature']))
              : const drift.Value.absent(),
        ),
      );
    }
  }
}
