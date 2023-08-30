import 'package:flutter/material.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/user_alert_notification.dart';

class AlertItem extends StatelessWidget {
  final UserAlertNotification alertNotification;
  final Function() onRemove;
  const AlertItem({
    super.key,
    required this.alertNotification,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/producer/device',
            arguments: {'device': alertNotification.device, 'producerId': null});
      },
      child: Card(
        elevation: 3,
        child: ListTile(
          leading: Icon(
            Icons.sensors,
            size: 30,
            color: theme.colorScheme.secondary,
          ),
          title: Text(alertNotification.device.imei),
          subtitle: Text(
              '${alertNotification.alert.parameter.toShortString(context).capitalize()} ${alertNotification.alert.comparisson.toShortString(context)} a ${alertNotification.alert.value}'),
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
