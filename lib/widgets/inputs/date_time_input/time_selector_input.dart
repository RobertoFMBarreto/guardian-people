import 'package:flutter/material.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';

class TimeSelectorInput extends StatelessWidget {
  final Function(DateTime)? onTimeChange;
  final DateTime time;
  const TimeSelectorInput({super.key, required this.onTimeChange, required this.time});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return TimePickerSpinner(
      locale: const Locale('pt', ''),
      time: time,
      is24HourMode: true,
      isShowSeconds: false,
      normalTextStyle: const TextStyle(
        fontSize: 20,
      ),
      highlightedTextStyle: TextStyle(
        fontSize: 30,
        color: theme.colorScheme.secondary,
      ),
      isForce2Digits: true,
      onTimeChange: onTimeChange,
      alignment: Alignment.center,
    );
  }
}
