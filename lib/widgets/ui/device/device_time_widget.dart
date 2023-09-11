import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/inputs/date_time_input.dart';
import 'package:guardian/widgets/ui/device/device_date_card.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DeviceTimeRangeWidget extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  const DeviceTimeRangeWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  State<DeviceTimeRangeWidget> createState() => _DeviceTimeRangeWidgetState();
}

class _DeviceTimeRangeWidgetState extends State<DeviceTimeRangeWidget> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    super.initState();
  }

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

  void _showStartDateDateSelector(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        AppLocalizations localizations = AppLocalizations.of(context)!;
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DateTimeInput(
                    onSelectionChanged: _onStartDateChanged,
                    date: widget.startDate,
                    onTimeChange: _onStartTimeChanged,
                    maxDate: widget.endDate,
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
                          widget.onStartDateChanged(_startDate);
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
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void _showEndDateDateSelector(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        AppLocalizations localizations = AppLocalizations.of(context)!;
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DateTimeInput(
                    onSelectionChanged: _onEndDateChanged,
                    date: widget.startDate,
                    onTimeChange: _onEndTimeChanged,
                    maxDate: widget.endDate,
                    minDate: widget.startDate,
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
                          widget.onEndDateChanged(_endDate);
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
          child: DeviceDateCard(
            date: widget.startDate,
            onTap: () {
              _showStartDateDateSelector(context);
            },
          ),
        ),
        Text(
          ' ${localizations.until.capitalize()} ',
          style: theme.textTheme.bodyLarge,
        ),
        Expanded(
          child: DeviceDateCard(
            date: widget.endDate,
            onTap: () {
              _showEndDateDateSelector(context);
            },
          ),
        ),
      ],
    );
  }
}
