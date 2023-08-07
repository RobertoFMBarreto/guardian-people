import 'package:flutter/material.dart';

class SquareDevicesInfo extends StatelessWidget {
  final String title;
  final String description;
  final bool isAlert;
  const SquareDevicesInfo({
    super.key,
    required this.title,
    required this.description,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: isAlert
              ? [
                  Color.fromRGBO(231, 75, 75, 1),
                  Color.fromRGBO(231, 130, 130, 1),
                ]
              : [
                  Color.fromRGBO(88, 200, 160, 1),
                  Color.fromRGBO(147, 215, 166, 1),
                ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    theme.textTheme.headlineSmall!.copyWith(color: theme.colorScheme.onSecondary),
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
      ),
    );
  }
}
