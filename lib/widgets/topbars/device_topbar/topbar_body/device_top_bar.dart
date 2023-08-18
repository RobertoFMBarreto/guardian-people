import 'package:flutter/material.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/widgets/topbars/device_topbar/topbar_body/device_min_top_bar.dart';
import 'package:guardian/widgets/topbars/device_topbar/topbar_body/no_background_device_top_bar.dart';

class DeviceTopBar extends StatelessWidget {
  final double extent;
  final Device device;
  final Widget? tailWidget;
  const DeviceTopBar(
      {super.key, required this.device, required this.extent, required this.tailWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 350,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color.fromRGBO(88, 200, 160, 1),
            Color.fromRGBO(147, 215, 166, 1),
          ],
        ),
      ),
      child: extent >= 70
          ? DeviceMinTopBar(
              device: device,
            )
          : NoBackgroundDeviceTopBar(device: device, tailWidget: tailWidget),
    );
  }
}
