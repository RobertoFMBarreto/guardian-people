import 'package:flutter/material.dart';
import 'package:guardian/models/alert.dart';
import 'package:guardian/models/device.dart';

class AlertItem extends StatelessWidget {
  final Alert alert;
  const AlertItem({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/producer/device', arguments: alert.device);
      },
      child: Card(
        elevation: 3,
        child: ListTile(
          leading: Icon(
            Icons.sensors,
            size: 30,
            color: theme.colorScheme.secondary,
          ),
          title: Text(alert.device.imei),
          subtitle: Text('Quando ${alert.parameter} ${alert.comparisson} a ${alert.value}'),
          trailing: IconButton(
            onPressed: () {
              //!TODO: Delete code for alert
            },
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
