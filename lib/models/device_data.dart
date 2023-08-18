import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum DeviceDataState {
  ruminating,
  eating,
  walking,
  running,
  fighting,
  stoped,
}

extension ParseCmpToString on DeviceDataState {
  String toShortString(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    String value = toString().split('.').last;
    print(value);
    switch (value) {
      case 'ruminating':
        return localizations.ruminating;

      case 'eating':
        return localizations.eating;

      case 'walking':
        return localizations.walking;

      case 'running':
        return localizations.running;

      case 'fighting':
        return localizations.fighting;

      case 'stopped':
        return localizations.stopped;

      default:
        return value;
    }
  }
}

class DeviceData {
  final int dataUsage;
  final double temperature;
  final int battery;
  final double lat;
  final double lon;
  final double elevation;
  final double accuracy;
  final DateTime dateTime;
  final DeviceDataState state;

  const DeviceData({
    required this.dataUsage,
    required this.battery,
    required this.elevation,
    required this.temperature,
    required this.lat,
    required this.lon,
    required this.accuracy,
    required this.dateTime,
    required this.state,
  });
}
