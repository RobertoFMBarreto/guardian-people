import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/operations/user_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/models/helpers/device_status.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/session_provider.dart';

/// Class that represents an animal item widget
class AnimalItem extends StatelessWidget {
  final Animal animal;
  final bool isBlocked;
  final Function? onBackFromDeviceScreen;
  final String? producerId;
  final Function()? onTap;
  final bool isSelected;
  final DeviceStatus deviceStatus;

  const AnimalItem({
    super.key,
    this.isBlocked = false,
    required this.animal,
    this.producerId,
    this.onBackFromDeviceScreen,
    this.onTap,
    this.isSelected = false,
    required this.deviceStatus,
  });

  /// Method that pushes to the correct device page
  void _onTapDevice(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;
      if (!kIsWeb && (width < 1000 && height < 1000)) {
        getUid(context).then((idUser) {
          if (idUser != null) {
            userIsAdmin(idUser).then((isAdmin) {
              Navigator.push(
                context,
                CustomPageRouter(
                    page: isAdmin ? '/admin/producer/device' : '/producer/device',
                    settings:
                        RouteSettings(arguments: {'animal': animal, 'producerId': producerId})),
              ).then((_) {
                if (!isAdmin && onBackFromDeviceScreen != null) onBackFromDeviceScreen!();
              });
            });
          }
        });
      } else {
        onTap!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card(
      color: isSelected ? theme.colorScheme.secondary : null,
      child: InkWell(
        onTap: () {
          _onTapDevice(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Icon(
              Icons.sensors,
              size: 35,
              color: HexColor(animal.animal.animalColor.value),
            ),
            title: Text(
              animal.animal.animalName.value,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            subtitle: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(radius: 3, backgroundColor: deviceStatus.toColor()),
                ),
                Text(deviceStatus.toNameString(context)),
              ],
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
                          color: isSelected
                              ? theme.colorScheme.onSecondary
                              : theme.colorScheme.secondary,
                        ),
                        Text(
                          '${animal.data.first.battery.value}%',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isSelected ? theme.colorScheme.onSecondary : null,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
