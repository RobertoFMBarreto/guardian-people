import 'package:guardian/models/db/drift/database.dart';

class Animal {
  final AnimalCompanion animal;
  final List<AnimalLocationsCompanion> data;

  Animal({
    required this.animal,
    required this.data,
  });
}
