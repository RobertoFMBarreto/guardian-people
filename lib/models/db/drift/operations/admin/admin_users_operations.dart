import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/producer_with_devices_amount.dart';

/// Allows to get the producer data
///
/// Gets the producer data based on [idUser] that is the id of the producer
///
/// Returns all all user data in [Future<UserData>]
Future<UserData> getProducer(BigInt idUser) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.user)..where((tbl) => tbl.idUser.equals(idUser))).getSingle();

  return data;
}

/// Allows to search producers and get the amount of devices they have
/// * `@param: [String]` - searchString
/// Based on the [searchString] searchs the producers by name and email
///
/// Finally returns [Future<List<ProducerWithDevicesAmount>>]
Future<List<ProducerWithDevicesAmount>> getProducersWithSearchAndDevicesAmount(
    String searchString) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT 
        ${db.user.actualTableName}.${db.user.idUser.name}, 
        ${db.user.actualTableName}.${db.user.email.name}, 
        ${db.user.actualTableName}.${db.user.name.name}, 
        ${db.user.actualTableName}.${db.user.phone.name},
        IFNULL(A.amount, 0) AS devicesAmount
      FROM ${db.user.actualTableName} 
      LEFT JOIN 
        (
          SELECT ${db.animal.idUser.name}, COUNT(${db.animal.idAnimal.name}) AS amount FROM ${db.animal.actualTableName} 
          GROUP BY ${db.animal.idUser.name}
        ) A ON A.${db.animal.idUser.name} = ${db.user.actualTableName}.${db.user.idUser.name}
      WHERE ${db.user.isSuperuser.name} = ? AND 
            (${db.user.actualTableName}.${db.user.name.name} LIKE ? OR ${db.user.email.name} LIKE ?)
    ''',
    variables: [
      Variable.withBool(false),
      Variable.withString('%$searchString%'),
      Variable.withString('%$searchString%')
    ],
  ).get();

  return data
      .map(
        (e) => ProducerWithDevicesAmount(
          devicesAmount: e.data['devicesAmount'],
          user: UserData.fromJson(e.data),
        ),
      )
      .toList();
}

Future<List<UserData>> getProducers() async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.user)..where((tbl) => tbl.isSuperuser.equals(false))).get();

  return data;
}
