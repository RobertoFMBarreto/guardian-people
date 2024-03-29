import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

/// Method to delete the intire database
Future<void> deleteEverything() {
  final db = Get.find<GuardianDb>();

  return db.transaction(() async {
    for (final table in db.allTables) {
      try {
        await db.delete(table).go();
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  });
}
