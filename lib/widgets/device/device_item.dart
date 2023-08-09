import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';
import 'package:guardian/models/providers/session_provider.dart';

class DeviceItem extends StatelessWidget {
  final String deviceImei;
  final int deviceData;
  final int deviceBattery;
  final bool isBlocked;
  final bool isPopPush;

  const DeviceItem({
    super.key,
    required this.deviceImei,
    required this.deviceData,
    required this.deviceBattery,
    this.isBlocked = false,
    this.isPopPush = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        getSessionRole().then((role) {
          if (isPopPush) {
            Navigator.of(context)
                .popAndPushNamed(role == 0 ? '/admin/producer/device' : '/producer/device');
          } else {
            Navigator.of(context)
                .pushNamed(role == 0 ? '/admin/producer/device' : '/producer/device');
          }
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            flex: 2,
            child: Icon(
              Icons.sensors,
              size: 35,
              color: gdSecondaryColor,
            ),
          ),
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    deviceImei.toString(),
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${deviceData.toString()}/10MB',
                    style: theme.textTheme.bodyMedium!.copyWith(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DeviceWidgetProvider.getBatteryWidget(
                  deviceBattery: deviceBattery,
                  color: theme.colorScheme.secondary,
                ),
                Text(
                  '${deviceBattery.toString()}%',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}