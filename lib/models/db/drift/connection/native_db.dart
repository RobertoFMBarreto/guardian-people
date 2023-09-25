import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'guardian_db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
