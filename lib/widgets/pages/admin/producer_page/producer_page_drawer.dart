import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/widgets/inputs/range_input.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Filtrar resultados',
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            RangeInput(
              currentRangeValues: batteryRangeValues,
              max: 100,
              min: 0,
              title: 'Bateria',
              label: '${batteryRangeValues.start.round()}% - ${batteryRangeValues.end.round()}%',
              onChanged: onChangedBat,
            ),
            RangeInput(
              currentRangeValues: dtUsageRangeValues,
              max: 10,
              min: 0,
              title: 'Dados usados',
              label: '${dtUsageRangeValues.start.round()}MB - ${dtUsageRangeValues.end.round()}MB',
              onChanged: onChangedDtUsg,
            ),
            RangeInput(
              currentRangeValues: tmpRangeValues,
              max: 35, //!TODO: Get maior tmp de todos os devices
              min: 0, //!TODO: Get menor tmp de todos os devices
              title: 'Temperatura do animal',
              label: '${tmpRangeValues.start.round()}ºC - ${tmpRangeValues.end.round()}ºC',
              onChanged: onChangedTmp,
            ),
            RangeInput(
              currentRangeValues: elevationRangeValues,
              max: 1500, //!TODO: Get maior altura de todos os devices
              min: 0, //!TODO: Get menor altura de todos os devices
              title: 'Elevação',
              label:
                  '${elevationRangeValues.start.round()}m - ${elevationRangeValues.end.round()}m',
              onChanged: onChangedElev,
            ),
            ElevatedButton(
              onPressed: onConfirm,
              child: const Text('Aplicar Filtros'),
            ),
            TextButton(
              onPressed: onResetFilters,
              child: Text(
                'Limpar Filtros',
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
