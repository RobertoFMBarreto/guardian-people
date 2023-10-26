import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/helpers/user_alert.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:get/get.dart';

/// Class that represents a selectable alert management item widget
class SelectableAlertManagementItem extends StatelessWidget {
  final UserAlertCompanion alert;
  final bool isSelected;
  final Function() onSelected;
  const SelectableAlertManagementItem(
      {super.key, required this.alert, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
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
                            text: '${localizations.when.capitalize!} ',
                            style: theme.textTheme.bodyLarge,
                            children: [
                              // TextSpan(
                              //   text:
                              //       '''${parseAlertParameterFromString(alert.parameter.value).toShortString(context).capitalize!} ${parseComparissonFromString(alert.comparisson.value).toShortString(context)} ${alert.comparisson.value == AlertComparissons.equal.toString() ? localizations.to : localizations.than} ${alert.conditionCompTo.value}''',
                              //   style: const TextStyle(fontWeight: FontWeight.bold),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "${localizations.notification.capitalize!}: ${alert.hasNotification.value ? localizations.yes.capitalize! : localizations.no.capitalize!}",
                        style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
