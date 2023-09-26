import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/inputs/date_time_input.dart';
import 'package:guardian/widgets/ui/animal/animal_date_card.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// Class that represents the animal time range widget
class AnimalTimeRangeWidget extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  const AnimalTimeRangeWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  State<AnimalTimeRangeWidget> createState() => _AnimalTimeRangeWidgetState();
}

class _AnimalTimeRangeWidgetState extends State<AnimalTimeRangeWidget> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    super.initState();
  }

  /// Method that sets the [_startDate] date keeping the backup time
  void _onStartDateChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      //store last date
      DateTime backupDate = _startDate;
      //store new date
      _startDate = args.value;
      //add the backup date hours to the new date
      _startDate = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        backupDate.hour,
        backupDate.minute,
      );
    });
  }

  /// Method that sets the [_startDate] time keeping the backup date
  void _onStartTimeChanged(DateTime newDate) {
    DateTime backup = _startDate;
    final newTime = DateTime(
      backup.year,
      backup.month,
      backup.day,
      newDate.hour,
      newDate.minute,
    );

    setState(() {
      _startDate = newTime;
    });
  }

  /// Method that sets the [_endDate] date keeping the backup time
  void _onEndDateChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      //store last date
      DateTime backupDate = _endDate;
      //store new date
      _endDate = args.value;
      //add the backup date hours to the new date
      _endDate = _endDate.add(
        Duration(
          hours: backupDate.hour,
          minutes: backupDate.minute,
        ),
      );
    });
  }

  /// Method that sets the [_endDate] time keeping the backup date
  void _onEndTimeChanged(DateTime newDate) {
    DateTime backup = _endDate;
    final newTime = DateTime(
      backup.year,
      backup.month,
      backup.day,
      newDate.hour,
      newDate.minute,
    );

    setState(() {
      _endDate = newTime;
    });
  }

  /// Method that shows the date picker dialogue
  void _showDateDateSelector(
    BuildContext context,
    AppLocalizations localizations, {
    required Function(DateRangePickerSelectionChangedArgs) onSelectionChanged,
    required DateTime date,
    required Function(DateTime) onTimeChange,
    required DateTime maxDate,
    DateTime? minDate,
    required bool isStartDate,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: Dialog(
            child: Container(
              constraints: kIsWeb ? const BoxConstraints(maxWidth: 400) : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DateTimeInput(
                      onSelectionChanged: onSelectionChanged,
                      date: date,
                      onTimeChange: onTimeChange,
                      maxDate: maxDate,
                      minDate: minDate,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            localizations.cancel.capitalize(),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (isStartDate) {
                              widget.onStartDateChanged(_startDate);
                            } else {
                              widget.onEndDateChanged(_endDate);
                            }
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            localizations.confirm.capitalize(),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: AnimalDateCard(
            date: widget.startDate,
            onTap: () {
              _showDateDateSelector(
                context,
                localizations,
                onSelectionChanged: _onStartDateChanged,
                date: widget.startDate,
                onTimeChange: _onStartTimeChanged,
                maxDate: widget.endDate,
                isStartDate: true,
              );
              //_showStartDateDateSelector(context, localizations);
            },
          ),
        ),
        Text(
          ' ${localizations.until.capitalize()} ',
          style: theme.textTheme.bodyLarge,
        ),
        Expanded(
          child: AnimalDateCard(
            date: widget.endDate,
            onTap: () {
              _showDateDateSelector(
                context,
                localizations,
                onSelectionChanged: _onEndDateChanged,
                date: widget.endDate,
                onTimeChange: _onEndTimeChanged,
                maxDate: DateTime.now(),
                minDate: widget.startDate,
                isStartDate: false,
              );
              // _showEndDateDateSelector(context, localizations);
            },
          ),
        ),
      ],
    );
  }
}
