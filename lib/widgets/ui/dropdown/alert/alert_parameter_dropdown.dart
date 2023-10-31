import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/helpers/user_alert.dart';
import 'package:get/get.dart';

/// Class that represents the alert parameter dropdown widget
class AlertParameterDropdown extends StatelessWidget {
  final AlertParameter value;
  final Function(AlertParameter?) onChanged;
  const AlertParameterDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: DropdownButton(
          isDense: true,
          borderRadius: BorderRadius.circular(20),
          underline: const SizedBox(),
          value: value,
          items: [
            DropdownMenuItem(
              value: AlertParameter.battery,
              child: Text(
                localizations.battery.capitalizeFirst!,
              ),
            ),
            DropdownMenuItem(
              value: AlertParameter.dataUsage,
              child: Text(
                localizations.data_used.capitalizeFirst!,
              ),
            ),
            DropdownMenuItem(
              value: AlertParameter.temperature,
              child: Text(
                localizations.temperature.capitalizeFirst!,
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
