import 'package:flutter/material.dart';
import 'package:guardian/widgets/inputs/date_time_input/date_selector_input.dart';
import 'package:guardian/widgets/inputs/date_time_input/time_selector_input.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateTimeInput extends StatefulWidget {
  final Function(DateRangePickerSelectionChangedArgs) onSelectionChanged;
  final Function(DateTime) onTimeChange;
  final DateTime date;
  final DateTime maxDate;
  final DateTime? minDate;
  const DateTimeInput({
    super.key,
    required this.onSelectionChanged,
    required this.date,
    required this.onTimeChange,
    required this.maxDate,
    this.minDate,
  });

  @override
  State<DateTimeInput> createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DateSelectorInput(
          onSelectionChanged: widget.onSelectionChanged,
          maxDate: widget.maxDate,
          initialDate: widget.date,
          minDate: widget.minDate,
        ),
        TimeSelectorInput(
          onTimeChange: widget.onTimeChange,
          time: widget.date,
        ),
      ],
    );
  }
}
