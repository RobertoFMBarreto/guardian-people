import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

String activityToString(BuildContext context, String value) {
  AppLocalizations localizations = AppLocalizations.of(context)!;
  switch (value) {
    case 'STILL':
      return localizations.still.capitalizeFirst!;

    case 'EATING':
      return localizations.eating.capitalizeFirst!;

    case 'GRAZING':
      return localizations.grazing.capitalizeFirst!;

    case 'RESTING':
      return localizations.resting.capitalizeFirst!;

    case 'STANDING':
      return localizations.standing.capitalizeFirst!;

    case 'WALKING':
      return localizations.walking.capitalizeFirst!;
    default:
      return value;
  }
}
