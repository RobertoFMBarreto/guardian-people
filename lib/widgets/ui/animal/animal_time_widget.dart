import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:guardian/main.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/inputs/date_time_input/time_selector_input.dart';
import 'package:guardian/widgets/ui/animal/animal_date_card.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// Class that represents the animal time range widget
class AnimalTimeRangeWidget extends StatefulWidget {
  final DateTime startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime) onDateChanged;
  const AnimalTimeRangeWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateChanged,
  });

  @override
  State<AnimalTimeRangeWidget> createState() => _AnimalTimeRangeWidgetState();
}

class _AnimalTimeRangeWidgetState extends State<AnimalTimeRangeWidget> {
  DateTime _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();

  @override
  void initState() {
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    super.initState();
  }

  /// Method that sets the [_startDate] time keeping the backup date
  /// Method that sets the [_endDate] date keeping the backup time
  void _onEndDateChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      //store last date
      DateTime backupDate = _endDate ?? DateTime.now();
      //store new date
      _endDate = args.value;
      //add the backup date hours to the new date
      _endDate = _endDate!.add(
        Duration(
          hours: backupDate.hour,
          minutes: backupDate.minute,
        ),
      );
    });
  }

  /// Method that sets the [_endDate] time keeping the backup date
  void _onEndTimeChanged(DateTime newDate) {
    DateTime backup = _endDate ?? DateTime.now();
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
        ThemeData theme = Theme.of(ctx);
        AppLocalizations localizations = AppLocalizations.of(ctx)!;
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: Dialog(
            child: Container(
              constraints: kIsWeb || isBigScreen ? const BoxConstraints(maxWidth: 400) : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SfDateRangePicker(
                      onSelectionChanged: (args) {
                        final range = args.value as PickerDateRange;
                        if (range.startDate != null) {
                          _startDate = DateTime(
                            range.startDate!.year,
                            range.startDate!.month,
                            range.startDate!.day,
                            _startDate.hour,
                            _startDate.minute,
                            _startDate.second,
                          );
                          _endDate = DateTime(
                            (range.endDate ?? range.startDate)!.year,
                            (range.endDate ?? range.startDate)!.month,
                            (range.endDate ?? range.startDate)!.day,
                            (_endDate ?? DateTime.now()).hour,
                            (_endDate ?? DateTime.now()).minute,
                            (_endDate ?? DateTime.now()).second,
                          );
                        }
                      },
                      selectionMode: DateRangePickerSelectionMode.range,
                      initialSelectedRange: PickerDateRange(
                        _startDate,
                        _endDate,
                      ),
                      initialDisplayDate: _startDate,
                      startRangeSelectionColor: theme.brightness == Brightness.light
                          ? gdSecondaryColor
                          : gdDarkSecondaryColor,
                      endRangeSelectionColor: theme.brightness == Brightness.light
                          ? gdSecondaryColor
                          : gdDarkSecondaryColor,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(localizations.start_date),
                            TimeSelectorInput(
                              onTimeChange: (time) {
                                _startDate = DateTime(
                                  _startDate.year,
                                  _startDate.month,
                                  _startDate.day,
                                  time.hour,
                                  time.minute,
                                  time.second,
                                );
                              },
                              time: DateTime.now(),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(localizations.end_date),
                            TimeSelectorInput(
                              onTimeChange: (time) {
                                _endDate = DateTime(
                                  (_endDate ?? DateTime.now()).year,
                                  (_endDate ?? DateTime.now()).month,
                                  (_endDate ?? DateTime.now()).day,
                                  time.hour,
                                  time.minute,
                                  time.second,
                                );
                              },
                              time: DateTime.now(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(localizations.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onDateChanged(_startDate, _endDate ?? DateTime.now());
                          },
                          child: Text(localizations.confirm),
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
            date: _startDate,
            onTap: () {
              _showDateDateSelector(
                context,
                localizations,
                onSelectionChanged: (date) {},
                date: _startDate,
                onTimeChange: (time) {},
                maxDate: widget.endDate ?? DateTime.now(),
                isStartDate: true,
              );
              //_showStartDateDateSelector(context, localizations);
            },
          ),
        ),
        Text(
          ' ${localizations.until.capitalizeFirst!} ',
          style: theme.textTheme.bodyLarge,
        ),
        Expanded(
          child: AnimalDateCard(
            date: _endDate,
            onTap: () {
              _showDateDateSelector(
                context,
                localizations,
                onSelectionChanged: _onEndDateChanged,
                date: _endDate ?? DateTime.now(),
                onTimeChange: _onEndTimeChanged,
                maxDate: DateTime.now(),
                minDate: widget.startDate,
                isStartDate: false,
              );
              // _showEndDateDateSelector(context, localizations);
            },
          ),
        ),
        // Expanded(
        //   child: AnimalDateCard(
        //     date: widget.startDate,
        //     onTap: () {
        //       _showDateDateSelector(
        //         context,
        //         localizations,
        //         onSelectionChanged: _onStartDateChanged,
        //         date: widget.startDate,
        //         onTimeChange: _onStartTimeChanged,
        //         maxDate: widget.endDate ?? DateTime.now(),
        //         isStartDate: true,
        //       );
        //       //_showStartDateDateSelector(context, localizations);
        //     },
        //   ),
        // ),
        // Text(
        //   ' ${localizations.until.capitalizeFirst!} ',
        //   style: theme.textTheme.bodyLarge,
        // ),
        // Expanded(
        //   child: AnimalDateCard(
        //     date: widget.endDate,
        //     onTap: () {
        //       _showDateDateSelector(
        //         context,
        //         localizations,
        //         onSelectionChanged: _onEndDateChanged,
        //         date: widget.endDate ?? DateTime.now(),
        //         onTimeChange: _onEndTimeChanged,
        //         maxDate: DateTime.now(),
        //         minDate: widget.startDate,
        //         isStartDate: false,
        //       );
        //       // _showEndDateDateSelector(context, localizations);
        //     },
        //   ),
        // ),
      ],
    );
  }
}
