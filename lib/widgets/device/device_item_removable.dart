import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';

class DeviceItemRemovable extends StatelessWidget {
  final String deviceTitle;
  final int deviceData;
  final int deviceBattery;
  final Function() onRemoveDevice;
  final bool isPopPush;

  const DeviceItemRemovable({
    super.key,
    required this.deviceTitle,
    required this.deviceData,
    required this.deviceBattery,
    required this.onRemoveDevice,
    this.isPopPush = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onRemoveDevice,
            child: const Icon(
              Icons.delete_forever,
              size: 35,
              color: gdErrorColor,
            ),
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
                  deviceTitle.toString(),
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
    );
  }
}
