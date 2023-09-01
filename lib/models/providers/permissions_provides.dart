import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Method for getting user permission for location services
///
Future<bool> handleLocationPermission(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    //!TODO: code to run when we dont have permission
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      //!TODO: code to run when the permission is denied
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    //!TODO: code to run when the permission is permanently denied
    return false;
  }
  return true;
}
