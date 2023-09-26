import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/inputs/date_time_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RangeDateTimeInput extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime, DateTime) onConfirm;
  const RangeDateTimeInput(
      {super.key, required this.onConfirm, required this.startDate, required this.endDate});

  @override
  State<RangeDateTimeInput> createState() => _RangeDateTimeInputState();
}

class _RangeDateTimeInputState extends State<RangeDateTimeInput>
    with SingleTickerProviderStateMixin {
  late DateTime _startDate;
  late DateTime _endDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _tabController = TabController(
      initialIndex: 0,
      vsync: this,
      length: 2,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onStartDateChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        //store last date
        DateTime backupDate = _startDate;
        //store new date
        _startDate = args.value;
        //add the backup date hours to the new date
        _startDate = _startDate.add(
          Duration(
            hours: backupDate.hour,
            minutes: backupDate.minute,
          ),
        );
      }
    });
  }

  void _onEndDateChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          indicatorColor: theme.colorScheme.secondary,
          controller: _tabController,
          tabs: [
            Tab(text: localizations.start_date.capitalize()),
            Tab(text: localizations.end_date.capitalize()),
          ],
          labelColor:
              Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        SizedBox(
          height: 500,
          width: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              //startDate
              DateTimeInput(
                onSelectionChanged: (args) {
                  _onStartDateChanged(args);
                },
                onTimeChange: (newDate) {
                  setState(() {
                    _startDate = newDate;
                  });
                },
                date: _startDate,
                maxDate: _endDate,
              ),
              //endDate
              DateTimeInput(
                onSelectionChanged: (args) {
                  _onEndDateChanged(args);
                },
                onTimeChange: (newDate) {
                  setState(() {
                    _endDate = newDate;
                  });
                },
                date: _endDate,
                maxDate: DateTime.now(),
                minDate: _startDate,
              ),
            ],
          ),
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
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: gdCancelBtnColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                widget.onConfirm(_startDate, _endDate);
              },
              child: Text(
                localizations.confirm.capitalize(),
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
