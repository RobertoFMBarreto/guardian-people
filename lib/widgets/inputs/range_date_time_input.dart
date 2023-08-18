import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/inputs/date_time_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late DateTime startDate;
  late DateTime endDate;
  late TabController _tabController;
  // List of Tabs
  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'Data Inicial'),
    const Tab(text: 'Data Final'),
  ];
  // controller object

  @override
  void initState() {
    super.initState();

    startDate = widget.startDate;
    endDate = widget.startDate;
    endDate = widget.endDate;
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          indicatorColor: Colors.green,
          controller: _tabController,
          tabs: [
            Tab(text: localizations.start_date.capitalize()),
            Tab(text: localizations.end_date.capitalize()),
          ],
          labelColor: Colors.black,
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
                  setState(() {
                    if (args.value is DateTime) {
                      //store last date
                      DateTime backupDate = startDate;
                      //store new date
                      startDate = args.value;
                      //add the backup date hours to the new date
                      startDate = startDate.add(
                        Duration(
                          hours: backupDate.hour,
                          minutes: backupDate.minute,
                        ),
                      );
                    }
                  });
                },
                onTimeChange: (newDate) {
                  setState(() {
                    startDate = newDate;
                  });
                },
                date: startDate,
                maxDate: endDate,
              ),
              //endDate
              DateTimeInput(
                onSelectionChanged: (args) {
                  setState(() {
                    if (args.value is DateTime) {
                      //store last date
                      DateTime backupDate = endDate;
                      //store new date
                      endDate = args.value;
                      //add the backup date hours to the new date
                      endDate = endDate.add(
                        Duration(
                          hours: backupDate.hour,
                          minutes: backupDate.minute,
                        ),
                      );
                    }
                  });
                },
                onTimeChange: (newDate) {
                  setState(() {
                    endDate = newDate;
                  });
                },
                date: endDate,
                maxDate: DateTime.now(),
                minDate: startDate,
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
                widget.onConfirm(startDate, endDate);
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
