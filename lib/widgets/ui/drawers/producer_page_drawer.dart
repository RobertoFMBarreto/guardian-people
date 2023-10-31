import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:get/get.dart';
import 'package:guardian/widgets/inputs/range_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the producer page drawer widget for filtering
class ProducerPageDrawer extends StatelessWidget {
  final RangeValues batteryRangeValues;
  final RangeValues dtUsageRangeValues;
  final RangeValues tmpRangeValues;
  final RangeValues elevationRangeValues;
  final Function(RangeValues)? onChangedBat;
  final Function(RangeValues)? onChangedDtUsg;
  final Function(RangeValues)? onChangedTmp;
  final Function(RangeValues)? onChangedElev;
  final Function()? onConfirm;
  final Function()? onResetFilters;
  final double maxTemp;
  final double maxElevation;
  const ProducerPageDrawer({
    super.key,
    required this.batteryRangeValues,
    required this.dtUsageRangeValues,
    required this.tmpRangeValues,
    required this.elevationRangeValues,
    required this.onConfirm,
    this.onChangedBat,
    this.onChangedDtUsg,
    this.onChangedTmp,
    this.onChangedElev,
    this.onResetFilters,
    required this.maxTemp,
    required this.maxElevation,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                '${localizations.filter.capitalizeFirst!} ${localizations.results}',
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            RangeInput(
              currentRangeValues: batteryRangeValues,
              max: 100,
              min: 0,
              title: localizations.battery.capitalizeFirst!,
              label: '${batteryRangeValues.start.round()}% - ${batteryRangeValues.end.round()}%',
              onChanged: onChangedBat,
            ),
            RangeInput(
              currentRangeValues: dtUsageRangeValues,
              max: 10,
              min: 0,
              title: localizations.data_used.capitalizeFirst!,
              label: '${dtUsageRangeValues.start.round()}MB - ${dtUsageRangeValues.end.round()}MB',
              onChanged: onChangedDtUsg,
            ),
            RangeInput(
              currentRangeValues: tmpRangeValues,
              max: maxTemp,
              min: 0,
              title: localizations.temperature.capitalizeFirst!,
              label: '${tmpRangeValues.start.round()}ºC - ${tmpRangeValues.end.round()}ºC',
              onChanged: onChangedTmp,
            ),
            RangeInput(
              currentRangeValues: elevationRangeValues,
              max: maxElevation,
              min: 0,
              title: localizations.elevation.capitalizeFirst!,
              label:
                  '${elevationRangeValues.start.round()}m - ${elevationRangeValues.end.round()}m',
              onChanged: onChangedElev,
            ),
            ElevatedButton(
              onPressed: onConfirm,
              child: Text(
                  '${localizations.apply.capitalizeFirst!} ${localizations.filters.capitalizeFirst!}'),
            ),
            TextButton(
              onPressed: onResetFilters,
              child: Text(
                '${localizations.clean.capitalizeFirst!} ${localizations.filters.capitalizeFirst!}',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: gdSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
