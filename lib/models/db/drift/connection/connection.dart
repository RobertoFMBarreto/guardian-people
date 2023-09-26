/// The objective is to import the correct package for the platform web/mobile
export 'unsupported.dart' if (dart.library.js) 'web_db.dart' if (dart.library.ffi) 'native_db.dart';
