import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

Future<void> deleteEverything() {
  final db = Get.find<GuardianDb>();
  return db.transaction(() async {
    // you only need this if you've manually enabled foreign keys
    // await customStatement('PRAGMA foreign_keys = OFF');
    for (final table in db.allTables) {
      await db.delete(table).go();
    }
  });
}
