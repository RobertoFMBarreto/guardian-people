import 'package:guardian/models/db/drift/database.dart';

class Animal {
  final AnimalCompanion animal;
  final List<DeviceLocationsCompanion> data;

  Animal({
    required this.animal,
    required this.data,
  });
}
