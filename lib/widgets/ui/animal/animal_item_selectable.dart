import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/helpers/device_helper.dart';

/// Class that represents an animal item widget that can be selected
class AnimalItemSelectable extends StatelessWidget {
  final String deviceImei;
  final int? deviceBattery;
  final bool isSelected;
  final Function() onSelected;
  final bool isPopPush;

  const AnimalItemSelectable({
    super.key,
    required this.deviceImei,
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
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
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
                flex: 11,
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
                    ],
                  ),
                ),
              ),
              if (deviceBattery != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
