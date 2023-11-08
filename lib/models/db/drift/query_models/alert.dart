import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

/// Class that represents an animal and all its locations data
///
/// The [alert] holds all information of the alert as an [UserAlertCompanion]
///
/// The [animals] holds all animals of the alert as a [List<Animal>]
class Alert {
  final UserAlertCompanion alert;
  final List<Animal> animals;

  Alert({
    required this.alert,
    required this.animals,
  });
}
