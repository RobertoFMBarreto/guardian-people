import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';

class DeviceItem extends StatelessWidget {
  final int deviceImei;
  final int deviceData;
  final int deviceBattery;
  final bool isBlocked;
  const DeviceItem({
    super.key,
    required this.deviceImei,
    required this.deviceData,
    required this.deviceBattery,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            flex: 1,
            child: Icon(Icons.sensors),
          ),
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceImei.toString(),
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    deviceData.toString(),
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: gdSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeviceWidgetProvider.getBatteryWidget(
                    deviceBattery: deviceBattery, color: theme.colorScheme.secondary),
                Text(
                  '${deviceBattery.toString()}%',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
