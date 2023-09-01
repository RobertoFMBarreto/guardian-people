import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    const Color.fromRGBO(88, 200, 160, 1),
                    const Color.fromRGBO(147, 215, 166, 1),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall!
                        .copyWith(color: theme.colorScheme.onSecondary),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      description,
                      style: theme.textTheme.headlineLarge!.copyWith(
                        fontSize: 45,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.hardEdge,
                child: isAlert
                    ? Icon(
                        Icons.warning,
                        size: 75,
                        color: theme.colorScheme.onSecondary.withOpacity(0.8),
                      )
                    : Transform.rotate(
                        angle: -35,
                        child: Icon(
                          Icons.sensors,
                          size: 75,
                          color: theme.colorScheme.onSecondary.withOpacity(0.8),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
