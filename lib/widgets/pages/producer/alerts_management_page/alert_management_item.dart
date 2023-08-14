import 'package:flutter/material.dart';
import 'package:guardian/models/alert.dart';

class AlertManagementItem extends StatelessWidget {
  final Alert alert;
  const AlertManagementItem({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
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
                    text: 'Quando ',
                    style: theme.textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text:
                            '${alert.parameter.toShortString()} ${alert.comparisson.toShortString()} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                RichText(
                  maxLines: 2,
                  text: TextSpan(
                    text: 'a ',
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
                "Notificação: ${alert.hasNotification ? 'Sim' : 'Não'}",
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
