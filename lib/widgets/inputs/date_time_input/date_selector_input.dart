import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateSelectorInput extends StatefulWidget {
  final Function(DateRangePickerSelectionChangedArgs) onSelectionChanged;
  final DateTime? initialDate;
  final DateTime maxDate;
  final DateTime? minDate;
  const DateSelectorInput({
    super.key,
    this.initialDate,
    required this.maxDate,
    this.minDate,
    required this.onSelectionChanged,
  });

  @override
  State<DateSelectorInput> createState() => _DateSelectorInputState();
}

class _DateSelectorInputState extends State<DateSelectorInput> {
  DateTime date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 300,
      child: SfDateRangePicker(
        onSelectionChanged: widget.onSelectionChanged,
        selectionMode: DateRangePickerSelectionMode.single,
        rangeSelectionColor: theme.colorScheme.secondary.withOpacity(0.5),
        startRangeSelectionColor: theme.colorScheme.secondary,
        endRangeSelectionColor: theme.colorScheme.secondary,
        selectionColor: theme.colorScheme.secondary,
        todayHighlightColor: Colors.black,
        selectionTextStyle: theme.textTheme.bodyLarge,
        yearCellStyle: const DateRangePickerYearCellStyle(
          leadingDatesDecoration: BoxDecoration(color: Colors.green),
          todayTextStyle: TextStyle(color: Colors.black),
          todayCellDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        monthCellStyle: const DateRangePickerMonthCellStyle(
          leadingDatesDecoration: BoxDecoration(color: Colors.green),
          todayTextStyle: TextStyle(color: Colors.black),
          todayCellDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        maxDate: widget.maxDate,
        minDate: widget.minDate,
        initialSelectedDate: widget.initialDate,
      ),
    );
  }
}
