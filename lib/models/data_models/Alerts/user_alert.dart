import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum AlertComparissons {
  equal,
  greater,
  less,
  greaterOrEqual,
  lessOrEqual,
}

enum AlertParameter {
  temperature,
  dataUsage,
  battery,
}

extension ParseCmpToString on AlertComparissons {
  String toShortString(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    String value = toString().split('.').last;
    switch (value) {
      case 'equal':
        return localizations.equal;

      case 'greater':
        return localizations.greater;

      case 'less':
        return localizations.less;

      case 'greaterOrEqual':
        return localizations.greaterOrEqual;

      case 'lessOrEqual':
        return localizations.lessOrEqual;

      default:
        return value;
    }
  }
}

extension ParseParToString on AlertParameter {
  String toShortString(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    String value = toString().split('.').last;
    switch (value) {
      case 'temperature':
        return localizations.temperature;

      case 'dataUsage':
        return localizations.data_used;

      case 'battery':
        return localizations.battery;

      default:
        return value;
    }
  }
}

const String tableUserAlerts = 'user_alerts';

class UserAlertFields {
  static const String alertId = 'alert_id';
  static const String uid = 'uid';
  static const String hasNotification = 'has_notification';
  static const String parameter = 'parameter';
  static const String comparisson = 'comparisson';
  static const String value = 'value';
  static const String deviceId = 'device_id';
}

class UserAlert {
  final String alertId;
  final String deviceId;
  final String uid;
  final bool hasNotification;
  final AlertParameter parameter;
  final AlertComparissons comparisson;
  final double value;

  UserAlert({
    required this.alertId,
    required this.deviceId,
    required this.uid,
    required this.hasNotification,
    required this.parameter,
    required this.comparisson,
    required this.value,
  });

  UserAlert copy({
    String? alertId,
    String? deviceId,
    String? uid,
    bool? hasNotification,
    AlertParameter? parameter,
    AlertComparissons? comparisson,
    double? value,
  }) =>
      UserAlert(
        alertId: alertId ?? this.alertId,
        deviceId: deviceId ?? this.deviceId,
        uid: uid ?? this.uid,
        hasNotification: hasNotification ?? this.hasNotification,
        parameter: parameter ?? this.parameter,
        comparisson: comparisson ?? this.comparisson,
        value: value ?? this.value,
      );

  Map<String, Object?> toJson() => {
        UserAlertFields.alertId: alertId,
        UserAlertFields.deviceId: deviceId,
        UserAlertFields.uid: uid,
        UserAlertFields.hasNotification: hasNotification ? 1 : 0,
        UserAlertFields.parameter: parameter,
        UserAlertFields.comparisson: comparisson,
        UserAlertFields.value: value,
      };

  static UserAlert fromJson(Map<String, Object?> json) => UserAlert(
        alertId: json[UserAlertFields.alertId] as String,
        deviceId: json[UserAlertFields.deviceId] as String,
        uid: json[UserAlertFields.uid] as String,
        hasNotification: json[UserAlertFields.hasNotification] == 1,
        parameter: json[UserAlertFields.parameter] as AlertParameter,
        comparisson: json[UserAlertFields.comparisson] as AlertComparissons,
        value: json[UserAlertFields.value] as double,
      );
}
