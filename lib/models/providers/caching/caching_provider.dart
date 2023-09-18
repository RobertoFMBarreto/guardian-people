import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapCaching {
  Future<void> initMapCaching() async {
    await FlutterMapTileCaching.initialise();
    await FMTC.instance('guardian').manage.createAsync();
  }
}
