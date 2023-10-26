import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/helpers/user_alert.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

/// Class that represents an alert item widget
class AlertItem extends StatelessWidget {
  final AlertNotification alertNotification;
  final Function() onRemove;
  const AlertItem({
    super.key,
    required this.alertNotification,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: () {
          Future.delayed(const Duration(milliseconds: 300)).then((value) => Navigator.push(
                context,
                CustomPageRouter(
                    page: '/producer/device',
                    settings: RouteSettings(
                        arguments: {'device': alertNotification.device, 'producerId': null})),
              ));
        },
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(
            Icons.sensors,
            size: 30,
            color: theme.colorScheme.secondary,
          ),
          title: Text(alertNotification.device.animal.animalName.value),
          subtitle: Text(
              '${parseSensor(alertNotification.alert.parameter.value, localizations).capitalize!} ${parseComparisson(alertNotification.alert.comparisson.value, localizations)} ${alertNotification.alert.comparisson.value == '=' ? localizations.to : localizations.than} ${alertNotification.alert.conditionCompTo.value}'),
          trailing: IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.delete_forever,
              size: 30,
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
