import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:guardian/models/helpers/custom_floating_btn_option.dart';

/// Class that represents a custom floating action button widget
class CustomFloatingActionButton extends StatelessWidget {
  final List<CustomFloatingActionButtonOption> options;
  const CustomFloatingActionButton({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SpeedDial(
      elevation: 7,
      backgroundColor: theme.colorScheme.secondary,
      foregroundColor: theme.colorScheme.onSecondary,
      activeBackgroundColor: theme.colorScheme.onSecondary,
      activeChild: Icon(
        Icons.close,
        color: theme.colorScheme.secondary,
      ),
      children: options
          .map(
            (e) => SpeedDialChild(
              label: e.title,
              elevation: 7,
              backgroundColor: theme.colorScheme.background,
              shape: const CircleBorder(),
              labelStyle: theme.textTheme.bodyLarge!.copyWith(
                color: theme.colorScheme.onBackground,
              ),
              child: Icon(
                e.icon,
              ),
              onTap: e.onTap,
            ),
          )
          .toList(),
      child: Icon(
        Icons.menu,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}
