import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/Device/device_data.dart';
import 'package:guardian/models/db/operations/device_data_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/ui/device/device_data_info_list_item.dart';

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
    _setup();
    super.initState();
  }

  Future<void> _setup() async {
    final now = DateTime.now();
    _selectedValue = DateTime(now.year, now.month, now.day);
    await _getDeviceData();
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
                  selectedDateStyle: TextStyle(
                    color: theme.colorScheme.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
              dayProps: EasyDayProps(
                dayStructure: DayStructure.monthDayNumDayStr,
                inactiveDayStyle: DayStyle(
                  dayNumStyle: TextStyle(
                    color: theme.colorScheme.onBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        theme.brightness == Brightness.dark ? gdDarkGradientStart : gdGradientStart,
                        theme.brightness == Brightness.dark ? gdDarkGradientEnd : gdGradientEnd,
                      ],
                    ),
                  ),
                ),
              ),
              initialDate: _selectedValue,
              activeColor: theme.colorScheme.secondary,
              locale: Localizations.localeOf(context).languageCode,
              onDateChange: (selectedDate) {
                setState(() {
                  _selectedValue = selectedDate;
                });
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
