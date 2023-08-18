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

const String tableDeviceData = 'devices_data';

class DeviceDataFields {
  static const String id = '_id';
  static const String deviceId = 'device_id';
  static const String dataUsage = 'data_usage';
  static const String temperature = 'temperature';
  static const String battery = 'battery';
  static const String lat = 'lat';
  static const String lon = 'lon';
  static const String elevation = 'elevation';
  static const String accuracy = 'accuracy';
  static const String dateTime = 'dateTime';
  static const String state = 'state';
}

class DeviceData {
  final int? id;
  final String deviceId;
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
    this.id,
    required this.deviceId,
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

  DeviceData copy({
    int? id,
    String? deviceId,
    int? dataUsage,
    double? temperature,
    int? battery,
    double? lat,
    double? lon,
    double? elevation,
    double? accuracy,
    DateTime? dateTime,
    DeviceDataState? state,
  }) =>
      DeviceData(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        dataUsage: dataUsage ?? this.dataUsage,
        battery: battery ?? this.battery,
        elevation: elevation ?? this.elevation,
        temperature: temperature ?? this.temperature,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        accuracy: accuracy ?? this.accuracy,
        dateTime: dateTime ?? this.dateTime,
        state: state ?? this.state,
      );

  Map<String, Object?> toJson() => {
        DeviceDataFields.id: id,
        DeviceDataFields.deviceId: deviceId,
        DeviceDataFields.dataUsage: dataUsage,
        DeviceDataFields.temperature: temperature,
        DeviceDataFields.battery: battery,
        DeviceDataFields.lat: lat,
        DeviceDataFields.lon: lon,
        DeviceDataFields.elevation: elevation,
        DeviceDataFields.accuracy: accuracy,
        DeviceDataFields.dateTime: dateTime.toIso8601String(),
        DeviceDataFields.state: state.toString(),
      };

  static DeviceData fromJson(Map<String, Object?> json) => DeviceData(
        id: json[DeviceDataFields.id] as int,
        deviceId: json[DeviceDataFields.deviceId] as String,
        dataUsage: json[DeviceDataFields.dataUsage] as int,
        battery: json[DeviceDataFields.battery] as int,
        elevation: json[DeviceDataFields.elevation] as double,
        temperature: json[DeviceDataFields.temperature] as double,
        lat: json[DeviceDataFields.lat] as double,
        lon: json[DeviceDataFields.lon] as double,
        accuracy: json[DeviceDataFields.accuracy] as double,
        dateTime: DateTime.parse(json[DeviceDataFields.dateTime] as String),
        state: json[DeviceDataFields.state] as DeviceDataState,
      );
}
