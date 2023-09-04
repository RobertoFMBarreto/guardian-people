import 'package:flutter/material.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/operations/user_operations.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/models/hex_color.dart';
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Icon(
              Icons.sensors,
              size: 35,
              color: HexColor(device.color),
            ),
            title: Text(
              device.name.toString(),
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            trailing: device.data != null && device.data!.isNotEmpty
                ? Column(
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
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
