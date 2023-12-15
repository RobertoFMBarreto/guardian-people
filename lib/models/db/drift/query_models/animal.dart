import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/helpers/device_status.dart';

/// Class that represents an animal and all its locations data
///
/// The [animal] holds all information of the animal as an [AnimalCompanion]
///
/// The [data] holds all locations data of the animal as a [List<AnimalLocationsCompanion>]
class Animal {
  final AnimalCompanion animal;
  final DeviceStatus? deviceStatus;
  final List<AnimalLocationsCompanion> data;

  Animal({
    required this.animal,
    this.deviceStatus,
    required this.data,
  });
}
