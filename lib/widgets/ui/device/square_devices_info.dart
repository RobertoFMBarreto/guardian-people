import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';

class SquareDevicesInfo extends StatelessWidget {
  final String title;
  final String description;
  final bool isAlert;
  final Function() onTap;
  const SquareDevicesInfo({
    super.key,
    required this.title,
    required this.description,
    this.isAlert = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: isAlert
              ? [
                  const Color.fromRGBO(231, 75, 75, 1),
                  const Color.fromRGBO(231, 130, 130, 1),
                ]
              : [
                  theme.brightness == Brightness.dark ? gdDarkGradientStart : gdGradientStart,
                  theme.brightness == Brightness.dark ? gdDarkGradientEnd : gdGradientEnd,
                ],
        ),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 20),
              child: Text(
                title,
                style:
                    theme.textTheme.headlineSmall!.copyWith(color: theme.colorScheme.onSecondary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    description,
                    style: theme.textTheme.headlineLarge!.copyWith(
                      fontSize: 45,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                  isAlert
                      ? Icon(
                          Icons.warning,
                          size: deviceHeight * 0.08,
                          color: theme.colorScheme.onSecondary.withOpacity(0.8),
                        )
                      : Transform.rotate(
                          angle: -35,
                          child: Icon(
                            Icons.sensors,
                            size: deviceHeight * 0.08,
                            color: theme.colorScheme.onSecondary.withOpacity(0.8),
                          ),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
