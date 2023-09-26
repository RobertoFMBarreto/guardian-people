import 'package:guardian/models/db/drift/database.dart';

/// Class that represents an animal and all its locations data
///
/// The [animal] holds all information of the animal as an [AnimalCompanion]
///
/// The [data] holds all locations data of the animal as a [List<AnimalLocationsCompanion>]
class Animal {
  final AnimalCompanion animal;
  final List<AnimalLocationsCompanion> data;

  Animal({
    required this.animal,
    required this.data,
  });
}
