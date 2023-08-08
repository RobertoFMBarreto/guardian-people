import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;

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

/// Method that allows to get device current location
/// @param onGetPosition -> Method to run when we get the device location
/// @param context -> current app context

Future<void> getCurrentPosition(
    Function(Position position) onGetPosition, BuildContext context) async {
  final hasPermission = await handleLocationPermission(context);
  if (!hasPermission) return;
  await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then(onGetPosition)
      .catchError(
    (e) {
      debugPrint(e);
    },
  );
}

/// Method that allows to get the distance in meters between two points
double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a =
      0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return (12742 * asin(sqrt(a))) * 1000;
}
