import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';

class DeviceTimeWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  const DeviceTimeWidget({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${localizations.from.capitalize()} ',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              '${startDate.day}/${startDate.month}/${startDate.year}',
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' ${localizations.until} ',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              '${endDate.day}/${endDate.month}/${endDate.year}',
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${localizations.from_time.capitalize()} ',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              '${startDate.hour <= 9 ? "0${startDate.hour}" : startDate.hour}:${startDate.minute <= 9 ? "0${startDate.minute}" : startDate.minute}',
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' ${localizations.until_time} ',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              '${endDate.hour <= 9 ? "0${endDate.hour}" : endDate.hour}:${endDate.minute <= 9 ? "0${endDate.minute}" : endDate.minute}',
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
