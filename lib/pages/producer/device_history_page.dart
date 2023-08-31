import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/db/device_data_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Device/device_data.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/pages/producer/device_page/device_data_info_list_item.dart';

class DeviceHistoryPage extends StatefulWidget {
  final Device device;
  const DeviceHistoryPage({super.key, required this.device});

  @override
  State<DeviceHistoryPage> createState() => _DeviceHistoryPageState();
}

class _DeviceHistoryPageState extends State<DeviceHistoryPage> {
  late DateTime _selectedValue;
  final firstItemDataKey = GlobalKey();
  List<DeviceData> deviceData = [];

  @override
  void initState() {
    // TODO: implement initState
    final now = DateTime.now();
    _selectedValue = DateTime(now.year, now.month, now.day);
    _getDeviceData();
    super.initState();
  }

  Future<void> _getDeviceData() async {
    getDeviceData(
      isInterval: true,
      deviceId: widget.device.deviceId,
      startDate: _selectedValue,
      endDate: DateTime(
        _selectedValue.year,
        _selectedValue.month,
        _selectedValue.day,
        23, // hour
        59, // minute
        59, // second
      ),
    ).then((newDeviceData) {
      setState(() {
        deviceData = [];
        deviceData.addAll(newDeviceData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.state_history.capitalize(),
          style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            EasyDateTimeLine(
              key: firstItemDataKey,
              headerProps: EasyHeaderProps(
                monthPickerType: MonthPickerType.dropDown,
                selectedDateFormat: SelectedDateFormat.fullDateDMonthAsStrY,
                monthStyle: theme.textTheme.bodyLarge,
              ),
              dayProps: EasyDayProps(
                dayStructure: DayStructure.monthDayNumDayStr,
                activeDayStyle: DayStyle(
                  dayNumStyle: TextStyle(
                    color: theme.colorScheme.onSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  monthStrStyle: TextStyle(
                    color: theme.colorScheme.onSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  dayStrStyle: TextStyle(
                    color: theme.colorScheme.onSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Color.fromRGBO(88, 200, 160, 1),
                        Color.fromRGBO(147, 215, 166, 1),
                      ],
                    ),
                  ),
                ),
              ),
              //TODO: Fix date to current date because the day 31 is broken
              initialDate: DateTime(2023, 8, 30),
              activeColor: theme.colorScheme.secondary,
              locale: Localizations.localeOf(context).languageCode,
              onDateChange: (selectedDate) {
                setState(() {
                  _selectedValue = selectedDate;
                });
                print(_selectedValue);
                _getDeviceData();
              },
            ),
            deviceData.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text(
                        localizations.no_data_to_show.capitalize(),
                      ),
                    ),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SingleChildScrollView(
                        child: DeviceDataInfoList(
                          mapKey: firstItemDataKey,
                          deviceData: deviceData,
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
