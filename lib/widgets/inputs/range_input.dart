import 'package:flutter/material.dart';

/// Class that represents the range input widget that shows the RangeSlider widget and a description
class RangeInput extends StatelessWidget {
  final String title;
  final String label;
  final double max;
  final double min;
  final Function(RangeValues)? onChanged;
  final RangeValues currentRangeValues;
  const RangeInput(
      {super.key,
      required this.max,
      required this.min,
      this.onChanged,
      required this.currentRangeValues,
      required this.title,
      required this.label});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              label,
              style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        RangeSlider(
            max: max,
            values: currentRangeValues,
            activeColor: theme.colorScheme.secondary,
            onChanged: onChanged),
      ],
    );
  }
}
