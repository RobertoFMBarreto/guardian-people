import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/extensions/string_extension.dart';

class AlertManagementItem extends StatelessWidget {
  final UserAlert alert;
  const AlertManagementItem({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  maxLines: 2,
                  text: TextSpan(
                    text: '${localizations.when.capitalize()} ',
                    style: theme.textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text:
                            '${alert.parameter.toShortString(context).capitalize()} ${alert.comparisson.toShortString(context)} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                RichText(
                  maxLines: 2,
                  text: TextSpan(
                    text: '${localizations.to} ',
                    style: theme.textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: alert.value.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "${localizations.notification.capitalize()}: ${alert.hasNotification ? localizations.yes.capitalize() : localizations.no.capitalize()}",
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            //!TODO: Delete code for alert
          },
          icon: Icon(
            Icons.delete_forever,
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}
