import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/helpers/user_alert.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:get/get.dart';

/// Class that represents an alert management item widget
class AlertManagementItem extends StatelessWidget {
  final UserAlertCompanion alert;
  final Function() onTap;
  final Function(UserAlertCompanion) onDelete;
  final bool isSelected;

  const AlertManagementItem({
    super.key,
    required this.alert,
    required this.onDelete,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Card(
      color: isSelected ? theme.colorScheme.secondary : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RichText(
                            maxLines: 2,
                            text: TextSpan(
                              text: '${localizations.when.capitalizeFirst!} ',
                              style: theme.textTheme.bodyLarge,
                              children: [
                                TextSpan(
                                  text:
                                      '${parseAlertParameterFromId(alert.parameter.value, localizations).capitalizeFirst!} ${parseComparissonFromString(alert.comparisson.value, localizations)} ${alert.comparisson.value != '=' ? localizations.than : localizations.to} ${getValue(alert.parameter.value, alert.conditionCompTo.value, localizations)}${getValueType(alert.parameter.value, localizations)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "${localizations.notification.capitalizeFirst!}: ${alert.hasNotification.value ? localizations.yes.capitalizeFirst! : localizations.no.capitalizeFirst!}",
                        style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasConnection)
                IconButton(
                  onPressed: () {
                    onDelete(alert);
                  },
                  icon: Icon(
                    Icons.delete_forever,
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
