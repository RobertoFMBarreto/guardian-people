import 'package:flutter/material.dart';
import 'package:guardian/models/db/data_models/Device/device_data.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/widgets/ui/common/icon_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DeviceDataInfoList extends StatefulWidget {
  final List<DeviceData> deviceData;
  final GlobalKey mapKey;
  const DeviceDataInfoList({super.key, required this.deviceData, required this.mapKey});

  @override
  State<DeviceDataInfoList> createState() => _DeviceDataInfoListState();
}

class _DeviceDataInfoListState extends State<DeviceDataInfoList> {
  int _currentTopicExtent = 10;
  List<bool> devicesDataInfo = [];
  List<bool> currentDevicesDataInfo = [];

  @override
  void initState() {
    if (widget.deviceData.length == 1) {
      devicesDataInfo.add(false);
    } else {
      devicesDataInfo = List.generate(10, (index) => false);
    }
    super.initState();
  }

  void getMoreInfo() {
    // TODO: code to get more 10 data info
    setState(() {
      devicesDataInfo.addAll(List.generate(10, (index) => false));

      _currentTopicExtent += 10;
    });
  }

  void showLessInfo() {
    // TODO: code to show less 10 data info
    setState(() {
      devicesDataInfo.removeRange(10, _currentTopicExtent);
      _currentTopicExtent = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        ExpansionPanelList(
          dividerColor: Colors.transparent,
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              devicesDataInfo[panelIndex] = !isExpanded;
            });
          },
          children: List.generate(
              devicesDataInfo.length,
              (index) => ExpansionPanel(
                    isExpanded: devicesDataInfo[index],
                    canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              if (!isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Container(
                                    height: 60,
                                    width: 2,
                                    decoration: const BoxDecoration(color: Colors.grey),
                                  ),
                                ),
                              Icon(
                                Icons.radio_button_checked,
                                color: theme.colorScheme.secondary,
                                size: 30,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: '${localizations.from_time.capitalize()} ',
                                    style: theme.textTheme.bodyLarge,
                                    children: [
                                      const TextSpan(
                                        text: '13:00 ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: '${localizations.until_time} '),
                                      const TextSpan(
                                        text: '14:00 ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: '${localizations.was} '),
                                      TextSpan(
                                        text: widget.deviceData[index].state
                                            .toShortString(context)
                                            .capitalize(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, localizations.localeName).format(widget.deviceData[index].dateTime)} ${localizations.at} ${DateFormat(DateFormat.HOUR_MINUTE, localizations.localeName).format(widget.deviceData[index].dateTime)}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                    body: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: IconText(
                                icon: Icons.sim_card,
                                iconColor: theme.colorScheme.secondary,
                                text: '${widget.deviceData.first.dataUsage}/10MB',
                                fontSize: 15,
                                iconSize: 25,
                              ),
                            ),
                            IconText(
                              icon: Icons.device_thermostat,
                              iconColor: theme.colorScheme.secondary,
                              text: '${widget.deviceData.first.temperature}ºC',
                              fontSize: 15,
                              iconSize: 30,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: IconText(
                                isInverted: true,
                                icon: Icons.landscape,
                                iconColor: theme.colorScheme.secondary,
                                text: '${widget.deviceData.first.elevation}m',
                                fontSize: 15,
                                iconSize: 30,
                              ),
                            ),
                            IconText(
                              icon: DeviceWidgetProvider.getBatteryIcon(
                                deviceBattery: 80,
                                color: theme.colorScheme.secondary,
                              ),
                              isInverted: true,
                              iconColor: theme.colorScheme.secondary,
                              text: '${widget.deviceData.first.battery}%',
                              fontSize: 15,
                              iconSize: 30,
                            ),
                          ],
                        )
                      ],
                    ),
                  )).toList(),
        ),
        if (widget.deviceData.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentTopicExtent > 10)
                TextButton.icon(
                    onPressed: () {
                      showLessInfo();

                      Scrollable.ensureVisible(widget.mapKey.currentContext!,
                          duration: const Duration(seconds: 1));
                    },
                    icon: Icon(Icons.remove, color: theme.colorScheme.secondary),
                    label: Text(
                      localizations.hide.capitalize(),
                      style:
                          theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.secondary),
                    )),
              TextButton.icon(
                  onPressed: () {
                    getMoreInfo();
                  },
                  icon: Icon(Icons.add, color: theme.colorScheme.secondary),
                  label: Text(
                    '${localizations.load.capitalize()} ${localizations.more} ${(widget.deviceData.length - _currentTopicExtent) >= 10 ? 10 : widget.deviceData.length - _currentTopicExtent}',
                    style: theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.secondary),
                  )),
            ],
          ),
      ],
    );
  }
}
