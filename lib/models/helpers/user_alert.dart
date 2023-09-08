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
  print(text);

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
