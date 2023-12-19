import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';

/// Class that represents the square animal info widget
class SquareAnimalsInfo extends StatelessWidget {
  final String title;
  final String description;
  final bool isFencing;
  final Function() onTap;
  const SquareAnimalsInfo({
    super.key,
    required this.title,
    required this.description,
    this.isFencing = false,
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
          colors: isFencing
              ? [
                  theme.brightness == Brightness.dark
                      ? gdDarkBlueGradientStart
                      : gdBlueGradientStart,
                  theme.brightness == Brightness.dark ? gdDarkBlueGradientEnd : gdBlueGradientEnd,
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
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  left: 10,
                  right: 10,
                ),
                child: Center(
                  child: Text(
                    title,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                  isFencing
                      ? Icon(
                          Icons.fence,
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
