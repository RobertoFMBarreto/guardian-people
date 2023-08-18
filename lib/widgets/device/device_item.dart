import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';

class DeviceItem extends StatelessWidget {
  final Device device;
  final bool isBlocked;
  final bool isPopPush;

  const DeviceItem({
    super.key,
    this.isBlocked = false,
    this.isPopPush = false,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        getSessionRole().then((role) {
          if (isPopPush) {
            Navigator.of(context).popAndPushNamed(
                role == 0 ? '/admin/producer/device' : '/producer/device',
                arguments: device);
          } else {
            Navigator.of(context).pushNamed(
                role == 0 ? '/admin/producer/device' : '/producer/device',
                arguments: device);
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
                    device.imei.toString(),
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${device.data.first.dataUsage.toString()}/10MB',
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
                  deviceBattery: device.data.first.battery,
                  color: theme.colorScheme.secondary,
                ),
                Text(
                  '${device.data.first.battery.toString()}%',
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
