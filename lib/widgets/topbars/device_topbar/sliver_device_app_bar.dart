import 'package:guardian/models/device.dart';
import 'package:guardian/widgets/topbars/device_topbar/no_background_device_top_bar.dart';
import 'package:guardian/widgets/topbars/device_topbar/path/custom_device_app_bar_wave_clipper.dart';
import 'package:guardian/widgets/topbars/main_topbar/device_info_body_top_bar.dart';
import 'package:guardian/widgets/topbars/main_topbar/path/custom_device_top_bar_wave_clipper.dart';
import 'package:flutter/material.dart';
import 'package:guardian/widgets/topbars/main_topbar/path/custom_main_top_bar_wave_clipper.dart';

class SliverDeviceAppBar extends SliverPersistentHeaderDelegate {
  Widget? leadingWidget;
  Widget? tailWidget;
  Widget? title;
  Device device;
  SliverDeviceAppBar({
    this.leadingWidget,
    this.tailWidget,
    this.title,
    required this.device,
  });
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    var adjustedShrinkOffset = shrinkOffset > minExtent ? minExtent : shrinkOffset;

    return SizedBox(
      height: 350,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: title ?? const SizedBox(),
            ),
          ),
          ClipPath(
            clipper: CustomDeviceAppBarWaveClipper(),
            child: NoBackgroundDeviceTopBar(
              device: device,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 350;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
}
