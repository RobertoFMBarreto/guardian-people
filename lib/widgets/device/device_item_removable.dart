import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';

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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          width: 0.5,
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: GestureDetector(
            onTap: onRemoveDevice,
            child: const Icon(
              Icons.delete_forever,
              size: 35,
              color: gdErrorColor,
            ),
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
    );
  }
}
