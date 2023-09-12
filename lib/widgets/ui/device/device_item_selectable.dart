import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/helpers/device_helper.dart';

class DeviceItemSelectable extends StatelessWidget {
  final String deviceImei;
  final int? deviceData;
  final int? deviceBattery;
  final bool isSelected;
  final Function() onSelected;
  final bool isPopPush;

  const DeviceItemSelectable({
    super.key,
    required this.deviceImei,
    required this.deviceData,
    required this.deviceBattery,
    required this.onSelected,
    this.isPopPush = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onSelected(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: deviceData != null
              ? const EdgeInsets.all(4.0)
              : const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 35,
                  color: gdSecondaryColor,
                ),
              ),
              Expanded(
                flex: deviceData != null ? 10 : 11,
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
                      if (deviceData != null)
                        Text(
                          '${deviceData.toString()}/10MB',
                          style: theme.textTheme.bodyMedium!.copyWith(),
                        ),
                    ],
                  ),
                ),
              ),
              if (deviceBattery != null)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DeviceWidgetProvider.getBatteryWidget(
                        deviceBattery: deviceBattery!,
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
      ),
    );
  }
}
