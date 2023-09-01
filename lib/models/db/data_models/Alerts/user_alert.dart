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

AlertParameter parseAlertParameterFromString(String text) {
  String value = text.toString().split('.').last;
  switch (value) {
    case 'temperature':
      return AlertParameter.temperature;

    case 'dataUsage':
      return AlertParameter.dataUsage;

    case 'battery':
      return AlertParameter.battery;

    default:
      throw Exception('Invalid alert parameter');
  }
}

AlertComparissons parseComparissonFromString(String text) {
  String value = text.toString().split('.').last;

  switch (value) {
    case 'equal':
      return AlertComparissons.equal;

    case 'greater':
      return AlertComparissons.greater;

    case 'less':
      return AlertComparissons.less;

    case 'greaterOrEqual':
      return AlertComparissons.greaterOrEqual;

    case 'lessOrEqual':
      return AlertComparissons.lessOrEqual;

    default:
      throw Exception('Invalid alert comparisson');
  }
}

const String tableUserAlerts = 'user_alerts';

class UserAlertFields {
  static const String alertId = 'alert_id';
  static const String hasNotification = 'has_notification';
  static const String parameter = 'parameter';
  static const String comparisson = 'comparisson';
  static const String value = 'value';
}

class UserAlert {
  final String alertId;
  final bool hasNotification;
  final AlertParameter parameter;
  final AlertComparissons comparisson;
  final double value;

  UserAlert({
    required this.alertId,
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
        hasNotification: hasNotification ?? this.hasNotification,
        parameter: parameter ?? this.parameter,
        comparisson: comparisson ?? this.comparisson,
        value: value ?? this.value,
      );

  Map<String, Object?> toJson() => {
        UserAlertFields.alertId: alertId,
        UserAlertFields.hasNotification: hasNotification ? 1 : 0,
        UserAlertFields.parameter: parameter.toString(),
        UserAlertFields.comparisson: comparisson.toString(),
        UserAlertFields.value: value,
      };

  static UserAlert fromJson(Map<String, Object?> json) {
    final parameter = parseAlertParameterFromString(json[UserAlertFields.parameter] as String);
    final comparisson = parseComparissonFromString(json[UserAlertFields.comparisson] as String);
    return UserAlert(
      alertId: json[UserAlertFields.alertId] as String,
      hasNotification: json[UserAlertFields.hasNotification] == 1,
      parameter: parameter,
      comparisson: comparisson,
      value: json[UserAlertFields.value] as double,
    );
  }
}
