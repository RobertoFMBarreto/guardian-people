// import 'package:flutter/material.dart';
// import 'package:guardian/models/device.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// enum AlertComparissons {
//   equal,
//   greater,
//   less,
//   greaterOrEqual,
//   lessOrEqual,
// }

// enum AlertParameter {
//   temperature,
//   dataUsage,
//   battery,
// }

// extension ParseCmpToString on AlertComparissons {
//   String toShortString(BuildContext context) {
//     AppLocalizations localizations = AppLocalizations.of(context)!;
//     String value = toString().split('.').last;
//     switch (value) {
//       case 'equal':
//         return localizations.equal;

//       case 'greater':
//         return localizations.greater;

//       case 'less':
//         return localizations.less;

//       case 'greaterOrEqual':
//         return localizations.greaterOrEqual;

//       case 'lessOrEqual':
//         return localizations.lessOrEqual;

//       default:
//         return value;
//     }
//   }
// }

// extension ParseParToString on AlertParameter {
//   String toShortString(BuildContext context) {
//     AppLocalizations localizations = AppLocalizations.of(context)!;
//     String value = toString().split('.').last;
//     switch (value) {
//       case 'temperature':
//         return localizations.temperature;

//       case 'dataUsage':
//         return localizations.data_used;

//       case 'battery':
//         return localizations.battery;

//       default:
//         return value;
//     }
//   }
// }

// class Alert {
//   final bool hasNotification;
//   final AlertParameter parameter;
//   final AlertComparissons comparisson;
//   final double value;
//   final Device device;

//   const Alert({
//     required this.device,
//     required this.hasNotification,
//     required this.parameter,
//     required this.comparisson,
//     required this.value,
//   });
// }
