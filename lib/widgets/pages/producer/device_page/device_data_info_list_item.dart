import 'package:flutter/material.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';
import 'package:guardian/widgets/icon_text.dart';

class DeviceDataInfoList extends StatefulWidget {
  final Device device;
  const DeviceDataInfoList({super.key, required this.device});

  @override
  State<DeviceDataInfoList> createState() => _DeviceDataInfoListState();
}

class _DeviceDataInfoListState extends State<DeviceDataInfoList> {
  List<bool> devicesDataInfo = [];
  @override
  void initState() {
    for (var _ in widget.device.data) {
      devicesDataInfo.add(false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ExpansionPanelList(
      dividerColor: Colors.transparent,
      expansionCallback: (panelIndex, isExpanded) {
        setState(() {
          devicesDataInfo[panelIndex] = !isExpanded;
        });
      },
      children: List.generate(
          widget.device.data.length,
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
                                text: 'Das ',
                                style: theme.textTheme.bodyLarge,
                                children: [
                                  const TextSpan(
                                    text: '13:00 ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(text: 'às '),
                                  const TextSpan(
                                    text: '14:00 ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(text: 'esteve a '),
                                  TextSpan(
                                    text: 'Ruminar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              widget.device.data[index].dateTime.toString(),
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
                            text: '${widget.device.data.first.dataUsage}/10MB',
                            fontSize: 15,
                            iconSize: 25,
                          ),
                        ),
                        IconText(
                          icon: Icons.device_thermostat,
                          iconColor: theme.colorScheme.secondary,
                          text: '${widget.device.data.first.temperature}ºC',
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
                            text: '${widget.device.data.first.elevation}m',
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
                          text: '${widget.device.data.first.battery}%',
                          fontSize: 15,
                          iconSize: 30,
                        ),
                      ],
                    )
                  ],
                ),
              )).toList(),
    );
  }
}
