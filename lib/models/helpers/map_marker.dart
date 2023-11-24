import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel with ClusterItem {
  String? id;
  final LatLng latLng;

  PlaceModel({required this.latLng, required this.id});
  @override
  LatLng get location => latLng;
}
