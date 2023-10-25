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

/// Extensions of [AlertComparissons]
extension ParseCmpToOp on AlertComparissons {
  /// Extension to parse from [AlertComparissons] to [String]
  String toOperator() {
    String value = toString().split('.').last;
    switch (value) {
      case 'equal':
        return '=';

      case 'greater':
        return '>';

      case 'less':
        return '<';

      case 'greaterOrEqual':
        return '>=';

      case 'lessOrEqual':
        return '<=';

      default:
        return value;
    }
  }
}

String parseComparisson(String op, AppLocalizations localizations) {
  switch (op) {
    case '=':
      return localizations.equal;

    case '>':
      return localizations.greater;

    case '<':
      return localizations.less;

    case '>=':
      return localizations.greaterOrEqual;

    case '<=':
      return localizations.lessOrEqual;

    default:
      return op;
  }
}

String parseSensor(String name, AppLocalizations localizations) {
  switch (name) {
    case 'Skin Temperature':
      return localizations.temperature;

    case 'dataUsage':
      return localizations.data_used;

    case 'Battery':
      return localizations.battery;

    default:
      return name;
  }
}

/// Method that parses from [text] [String] to [AlertParameter]
String parseAlertParameterFromId(String text, AppLocalizations localizations) {
  switch (text) {
    case 'fa6917df-ed01-45f2-bb55-a9a25b5a470a':
      return localizations.temperature;

    case '33246c98-651a-4a73-aeff-0ab248de0a32':
      return 'altitude';

    case 'a5f677a6-f3a4-495a-9ae9-f19c5997bb69':
      return localizations.battery;

    default:
      throw Exception('Invalid alert parameter');
  }
}

/// Method that parses from [text] [String] to [AlertComparissons]
String parseComparissonFromString(String text, AppLocalizations localizations) {
  switch (text) {
    case '=':
      return localizations.equal;

    case '>':
      return localizations.greater;

    case '<':
      return localizations.less;

    case '>=':
      return localizations.greaterOrEqual;

    case '<=':
      return localizations.lessOrEqual;

    default:
      throw Exception('Invalid alert comparisson');
  }
}
