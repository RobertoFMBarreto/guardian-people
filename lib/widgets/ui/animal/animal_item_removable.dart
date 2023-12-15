import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/device_helper.dart';

/// Class that represents an animal item widget that can be removed
class AnimalItemRemovable extends StatelessWidget {
  final Animal animal;
  final Function() onRemoveDevice;
  final bool isPopPush;

  const AnimalItemRemovable({
    super.key,
    required this.animal,
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
            animal.animal.animalName.value.toString(),
            style: theme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          trailing: animal.data.isNotEmpty && animal.data.first.battery.value != null
              ? SizedBox(
                  width: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DeviceWidgetProvider.getBatteryWidget(
                        deviceBattery: animal.data.first.battery.value!,
                        color: theme.colorScheme.secondary,
                      ),
                      Text(
                        '${animal.data.first.battery.value.toString()}%',
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
