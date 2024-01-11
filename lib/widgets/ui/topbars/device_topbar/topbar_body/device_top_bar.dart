import 'package:flutter/material.dart';
import 'package:guardian/models/helpers/device_status.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/topbar_body/device_min_top_bar.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/topbar_body/no_background_device_top_bar.dart';

/// Class that represents the default animal top bar
class DeviceTopBar extends StatelessWidget {
  final double extent;
  final Animal device;
  final Widget? tailWidget;
  final Function(String)? onColorChanged;
  final double maxHeight;
  const DeviceTopBar({
    super.key,
    required this.device,
    required this.maxHeight,
    required this.extent,
    required this.tailWidget,
    this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: maxHeight,
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
      child: extent >= 70
          ? DeviceMinTopBar(
              animal: device,
            )
          : NoBackgroundDeviceTopBar(
              animal: device,
              tailWidget: tailWidget,
              onColorChanged: onColorChanged!,
              maxHeight: maxHeight,
              deviceStatus: device.data.isEmpty
                  ? DeviceStatus.offline
                  : device.data.isNotEmpty &&
                          device.data.first.lat.value == null &&
                          device.data.first.lon.value == null
                      ? DeviceStatus.noGps
                      : DeviceStatus.online,
            ),
    );
  }
}
