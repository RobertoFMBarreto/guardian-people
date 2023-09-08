import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/topbar_body/device_min_top_bar.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/topbar_body/no_background_device_top_bar.dart';

class DeviceTopBar extends StatelessWidget {
  final double extent;
  final Device device;
  final Widget? tailWidget;
  final Function(String)? onColorChanged;
  const DeviceTopBar({
    super.key,
    required this.device,
    required this.extent,
    required this.tailWidget,
    this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 350,
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
              device: device,
            )
          : NoBackgroundDeviceTopBar(
              device: device,
              tailWidget: tailWidget,
              onColorChanged: onColorChanged!,
            ),
    );
  }
}
