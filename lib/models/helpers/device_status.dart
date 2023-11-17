import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

enum DeviceStatus { online, offline, noGps }

/// Extensions of [DeviceStatus]
extension ParseDeviceStatus on DeviceStatus {
  /// Extension to parse from [DeviceStatus] to [String]
  String toNameString(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    String value = toString().split('.').last;
    switch (value) {
      case 'online':
        return localizations.online.capitalizeFirst!;

      case 'offline':
        return localizations.offline.capitalizeFirst!;

      case 'noGps':
        return localizations.no_gps.capitalizeFirst!;
      default:
        return value;
    }
  }
}

/// Extensions of [DeviceStatus]
extension ParseDeviceStatusColors on DeviceStatus {
  /// Extension to parse from [DeviceStatus] to [Color]
  Color toColor() {
    String value = toString().split('.').last;
    switch (value) {
      case 'online':
        return Colors.green;

      case 'offline':
        return Colors.red;

      case 'noGps':
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }
}
