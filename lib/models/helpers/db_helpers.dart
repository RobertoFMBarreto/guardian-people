import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

/// Method to delete the intire database
Future<void> deleteEverything() {
  final db = Get.find<GuardianDb>();
  db.allTables.forEach((element) {
    print('[TABLE1]${element.actualTableName}');
  });
  return db.transaction(() async {
    for (final table in db.allTables) {
      try {
        await db.delete(table).go();
      } catch (e) {
        print(e);
      }
    }
  });
}
