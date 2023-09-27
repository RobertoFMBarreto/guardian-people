import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This enum holds the comparisson options of an [UserAlert]
enum AlertComparissons {
  equal,
  greater,
  less,
  greaterOrEqual,
  lessOrEqual,
}

/// This enum holds the parameters of an [UserAlert]
enum AlertParameter {
  temperature,
  dataUsage,
  battery,
}

/// Extensions of [AlertComparissons]
extension ParseCmpToString on AlertComparissons {
  /// Extension to parse from [AlertComparissons] to [String]
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

/// Extensions of [AlertParameter]
extension ParseParToString on AlertParameter {
  /// Extension to parse from [AlertParameter] to [String]
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

/// Method that parses from [text] [String] to [AlertParameter]
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

/// Method that parses from [text] [String] to [AlertComparissons]
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
