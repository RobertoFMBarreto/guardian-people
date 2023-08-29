import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/user_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';
import 'package:guardian/models/providers/session_provider.dart';

class DeviceItem extends StatelessWidget {
  final Device device;
  final bool isBlocked;
  final bool isPopPush;
  final Function? onBackFromDeviceScreen;
  final String producerId;

  const DeviceItem({
    super.key,
    this.isBlocked = false,
    this.isPopPush = false,
    required this.device,
    this.producerId = '',
    this.onBackFromDeviceScreen,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        getUid(context).then((uid) {
          if (uid != null) {
            userIsAdmin(uid).then((isAdmin) {
              if (isPopPush) {
                Navigator.of(context).popAndPushNamed(
                    isAdmin ? '/admin/producer/device' : '/producer/device',
                    arguments: {'device': device, 'producerId': producerId}).then((_) {
                  if (!isAdmin && onBackFromDeviceScreen != null) onBackFromDeviceScreen!();
                });
              } else {
                Navigator.of(context).pushNamed(
                    isAdmin ? '/admin/producer/device' : '/producer/device',
                    arguments: {'device': device, 'producerId': producerId}).then((_) {
                  if (!isAdmin && onBackFromDeviceScreen != null) onBackFromDeviceScreen!();
                });
              }
            });
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
                    device.name.toString(),
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  // Text(
                  //   '${device.data!.first.dataUsage.toString()}/10MB',
                  //   style: theme.textTheme.bodyMedium!.copyWith(),
                  // ),
                ],
              ),
            ),
          ),
          if (device.data != null)
            if (device.data!.isNotEmpty)
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DeviceWidgetProvider.getBatteryWidget(
                      deviceBattery: device.data!.first.battery,
                      color: theme.colorScheme.secondary,
                    ),
                    Text(
                      '${device.data!.first.battery.toString()}%',
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
