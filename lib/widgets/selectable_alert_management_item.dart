import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/extensions/string_extension.dart';

class SelectableAlertManagementItem extends StatelessWidget {
  final UserAlert alert;
  final bool isSelected;
  final Function() onSelected;
  const SelectableAlertManagementItem(
      {super.key, required this.alert, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onSelected,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 35,
              color: gdSecondaryColor,
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
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
          ),
        ],
      ),
    );
  }
}
