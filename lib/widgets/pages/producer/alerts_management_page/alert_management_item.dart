import 'package:flutter/material.dart';
import 'package:guardian/models/alert.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/widgets/color_circle.dart';

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
            RichText(
              text: TextSpan(
                text: 'Quando ',
                style: theme.textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: '${alert.parameter} ${alert.comparisson} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'a ',
                    style: theme.textTheme.bodyLarge,
                  ),
                  TextSpan(
                    text: alert.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Cor:',
                          style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ColorCircle(
                        color: HexColor(alert.color),
                      ),
                    ],
                  ),
                  Text(
                    "Notificação: ${alert.hasNotification ? 'Sim' : 'Não'}",
                    style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
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
            size: 30,
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}
