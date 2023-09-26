import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Creates a connection to the web sqlite database using wasm
///
/// `@returns: [DatabaseConnection]` - Database connection
DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'guardian_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );
    return result.resolvedExecutor;
  }));
}
