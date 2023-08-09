import 'package:flutter/material.dart';

class DeviceTimeWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  const DeviceTimeWidget({super.key, required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return startDate.compareTo(endDate) == 0
        ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'De',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        '${startDate.day}/${startDate.month}/${startDate.year}',
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Até',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        '${startDate.day}/${startDate.month}/${startDate.year}',
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Das',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        '${startDate.hour <= 9 ? "0${startDate.hour}" : startDate.hour}:${startDate.minute <= 9 ? "0${startDate.minute}" : startDate.minute}',
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'às',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        '${startDate.hour <= 9 ? "0${startDate.hour}" : startDate.hour}:${startDate.minute <= 9 ? "0${startDate.minute}" : startDate.minute}',
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Text(
            'Dia ${startDate.day}/${startDate.month}/${startDate.year} às ${startDate.hour <= 9 ? "0${startDate.hour}" : startDate.hour}:${startDate.minute <= 9 ? "0${startDate.minute}" : startDate.minute}',
            style: theme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w500,
            ),
          );
  }
}
