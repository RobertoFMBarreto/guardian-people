import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/widgets/inputs/range_date_time_input.dart';
import 'package:guardian/widgets/pages/producer/device_page/device_time_widget.dart';
import 'package:guardian/widgets/topbars/device_topbar/sliver_device_app_bar.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DevicePage extends StatefulWidget {
  final Device device;
  const DevicePage({super.key, required this.device});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime startDateBackup = DateTime.now();
  DateTime endDateBackup = DateTime.now();
  bool isInterval = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverDeviceAppBar(
                title: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Localização',
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ToggleSwitch(
                        initialLabelIndex: 0,
                        cornerRadius: 50,
                        radiusStyle: true,
                        activeBgColor: [theme.colorScheme.secondary],
                        activeFgColor: theme.colorScheme.onSecondary,
                        inactiveBgColor: gdToggleGreyArea,
                        inactiveFgColor: Colors.black,
                        customTextStyles: const [
                          TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                          TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                        ],
                        totalSwitches: 2,
                        labels: const [
                          'Atual',
                          'Intervalo',
                        ],
                        onToggle: (index) {
                          setState(() {
                            isInterval = index == 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                device: widget.device,
                leadingWidget: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSecondary,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                tailWidget: IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: theme.colorScheme.onSecondary,
                    size: 30,
                  ),
                  onPressed: () {
                    //TODO: Code for settings of device
                  },
                ),
              ),
            ),
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isInterval)
                            DeviceTimeWidget(
                              startDate: startDate,
                              endDate: endDate,
                              onStartDateTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RangeDateTimeInput(
                                            startDate: startDate,
                                            endDate: endDate,
                                            onConfirm: (newStartDate, newEndDate) {
                                              setState(() {
                                                startDate = newStartDate;
                                                endDate = newEndDate;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          // child: DateTimeInput(
                                          //   initialDate: startDate,
                                          //   maxDate: endDate,
                                          //   onConfirm: (selectedDate) {
                                          //     setState(() {
                                          //       startDate = selectedDate;
                                          //     });
                                          //     Navigator.of(context).pop();
                                          //   },
                                          // ),
                                        ),
                                      );
                                    });
                              },
                              onEndDateTap: () {
                                // showDialog(
                                //     context: context,
                                //     builder: (context) {
                                //       return DateTimeInput(
                                //         initialDate: endDate,
                                //         maxDate: DateTime.now(),
                                //         minDate: startDate,
                                //         onConfirm: (selectedDate) {
                                //           setState(() {
                                //             endDate = selectedDate;
                                //           });
                                //           Navigator.of(context).pop();
                                //         },
                                //       );
                                //     });
                              },
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
