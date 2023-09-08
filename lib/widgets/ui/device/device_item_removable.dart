import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/helpers/device_helper.dart';

class DeviceItemRemovable extends StatelessWidget {
  final Device device;
  final Function() onRemoveDevice;
  final bool isPopPush;

  const DeviceItemRemovable({
    super.key,
    required this.device,
    required this.onRemoveDevice,
    this.isPopPush = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: hasConnection
              ? GestureDetector(
                  onTap: onRemoveDevice,
                  child: const Icon(
                    Icons.delete_forever,
                    size: 35,
                    color: gdErrorColor,
                  ),
                )
              : null,
          title: Text(
            device.device.name.value.toString(),
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
    );
  }
}
