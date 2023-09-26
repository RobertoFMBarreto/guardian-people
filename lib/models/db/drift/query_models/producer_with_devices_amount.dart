import 'package:guardian/models/db/drift/database.dart';

/// This class representes a producer and the amount of devices he has
///
/// The [devicesAmount] holds the amount of devices of the producer
///
/// The [user] holds all of the producer information as an [UserData]
class ProducerWithDevicesAmount {
  final int devicesAmount;
  final UserData user;

  const ProducerWithDevicesAmount({required this.devicesAmount, required this.user});
}
