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
  static const String id = '_id';
  static const String alertId = 'alert_id';
  static const String hasNotification = 'has_notification';
  static const String parameter = 'parameter';
  static const String comparisson = 'comparisson';
  static const String value = 'value';
}

class UserAlert {
  final int? id;
  final String alertId;
  final bool hasNotification;
  final AlertParameter parameter;
  final AlertComparissons comparisson;
  final double value;

  UserAlert({
    this.id,
    required this.alertId,
    required this.hasNotification,
    required this.parameter,
    required this.comparisson,
    required this.value,
  });

  UserAlert copy({
    int? id,
    String? alertId,
    bool? hasNotification,
    AlertParameter? parameter,
    AlertComparissons? comparisson,
    double? value,
    String? deviceId,
  }) =>
      UserAlert(
        id: id ?? this.id,
        alertId: alertId ?? this.alertId,
        hasNotification: hasNotification ?? this.hasNotification,
        parameter: parameter ?? this.parameter,
        comparisson: comparisson ?? this.comparisson,
        value: value ?? this.value,
      );

  Map<String, Object?> toJson() => {
        UserAlertFields.id: id,
        UserAlertFields.alertId: alertId,
        UserAlertFields.hasNotification: hasNotification,
        UserAlertFields.parameter: parameter,
        UserAlertFields.comparisson: comparisson,
        UserAlertFields.value: value,
      };

  static UserAlert fromJson(Map<String, Object?> json) => UserAlert(
        id: json[UserAlertFields.id] as int,
        alertId: json[UserAlertFields.alertId] as String,
        hasNotification: json[UserAlertFields.hasNotification] == 1,
        parameter: json[UserAlertFields.parameter] as AlertParameter,
        comparisson: json[UserAlertFields.comparisson] as AlertComparissons,
        value: json[UserAlertFields.value] as double,
      );
}
