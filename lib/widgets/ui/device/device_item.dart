import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/user_operations.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
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

  void _onTapDevice(BuildContext context) {
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
            Navigator.of(context).pushNamed(isAdmin ? '/admin/producer/device' : '/producer/device',
                arguments: {'device': device, 'producerId': producerId}).then((_) {
              if (!isAdmin && onBackFromDeviceScreen != null) onBackFromDeviceScreen!();
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        _onTapDevice(context);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Icon(
              Icons.sensors,
              size: 35,
              color: HexColor(device.device.color.value),
            ),
            title: Text(
              device.device.name.value,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            trailing: device.data.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DeviceWidgetProvider.getBatteryWidget(
                        deviceBattery: device.data.first.battery.value,
                        color: theme.colorScheme.secondary,
                      ),
                      Text(
                        '${device.data.first.battery.value.toString()}%',
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
