import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/widgets/ui/common/icon_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// class that represents the rounded body os animal top bar
class DeviceRoundedWhiteBodyInfo extends StatelessWidget {
  final Animal device;
  const DeviceRoundedWhiteBodyInfo({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Container(
      width: deviceWidth,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            theme.brightness == Brightness.dark ? gdDarkGradientStart : gdGradientStart,
            theme.brightness == Brightness.dark ? gdDarkGradientEnd : gdGradientEnd,
          ],
        ),
      ),
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: deviceWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSecondary,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 10),
              child: Container(
                width: deviceWidth,
                height: 250,
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      localizations.device_data.capitalizeFirst!,
                      style: theme.textTheme.headlineMedium,
                    ),
                    if (device.data.isNotEmpty)
                      Text(
                        localizations.no_device_data.capitalizeFirst!,
                        style: theme.textTheme.bodyLarge!.copyWith(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    if (device.data.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconText(
                            isInverted: true,
                            icon: Icons.landscape,
                            iconColor: theme.colorScheme.secondary,
                            text: '${device.data.first.elevation.value!.round()}m',
                            fontSize: 23,
                            iconSize: 30,
                          ),
                        ],
                      ),
                    if (device.data.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconText(
                            icon: Icons.device_thermostat,
                            iconColor: theme.colorScheme.secondary,
                            text: '${device.data.first.temperature}ºC',
                            fontSize: 23,
                            iconSize: 30,
                          ),
                          IconText(
                            icon: DeviceWidgetProvider.getBatteryIcon(
                              deviceBattery: 80,
                              color: theme.colorScheme.secondary,
                            ),
                            isInverted: true,
                            iconColor: theme.colorScheme.secondary,
                            text: '${device.data.first.battery}%',
                            fontSize: 23,
                            iconSize: 30,
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
