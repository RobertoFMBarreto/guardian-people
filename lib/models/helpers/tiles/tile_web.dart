import 'package:flutter_map/flutter_map.dart';

/// Method that returns no caching tile provider for web users
TileProvider? getTileProvider(String instance) => null;
