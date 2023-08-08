import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';

class DeviceItem extends StatelessWidget {
  final String deviceImei;
  final int deviceData;
  final int deviceBattery;
  final bool isBlocked;
  final bool isRemoveMode;
  final Function()? onRemoveDevice;
  final bool isPopPush;

  const DeviceItem({
    super.key,
    required this.deviceImei,
    required this.deviceData,
    required this.deviceBattery,
    this.isRemoveMode = false,
    this.isBlocked = false,
    this.onRemoveDevice,
    this.isPopPush = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (isPopPush) {
          Navigator.of(context).popAndPushNamed('/admin/producer/device');
        } else {
          Navigator.of(context).pushNamed('/admin/producer/device');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 8.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: isRemoveMode ? onRemoveDevice : null,
                child: Icon(
                  isRemoveMode ? Icons.delete_forever : Icons.sensors,
                  size: 35,
                  color: isRemoveMode ? gdErrorColor : gdSecondaryColor,
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
      ),
    );
  }
}
