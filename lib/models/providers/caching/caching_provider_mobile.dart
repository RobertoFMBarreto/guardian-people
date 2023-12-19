import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

/// Class responsible for setting up the map caching
class MapCaching {
  // Method that starts the map caching for mobile
  Future<void> initMapCaching() async {
    await FlutterMapTileCaching.initialise();
    await FMTC.instance('guardian').manage.createAsync();
  }
}
