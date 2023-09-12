import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/path/custom_d_top_bar_clipper.dart';
import 'package:flutter/material.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/path/custom_inverted_d_top_bar_clipper.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/topbar_body/device_rounded_white_body_info.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/topbar_body/device_top_bar.dart';

class SliverDeviceAppBar extends SliverPersistentHeaderDelegate {
  Widget? leadingWidget;
  Widget? tailWidget;
  Widget? title;
  Device device;
  bool isWhiteBody;
  Function(String)? onColorChanged;

  double maxHeight;
  SliverDeviceAppBar({
    this.leadingWidget,
    this.tailWidget,
    this.title,
    this.onColorChanged,
    this.isWhiteBody = false,
    required this.device,
    required this.maxHeight,
  });
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    var adjustedShrinkOffset = shrinkOffset > minExtent ? minExtent : shrinkOffset;

    return SizedBox(
      height: maxHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              child: title ?? const SizedBox(),
            ),
          ),
          ClipPath(
            clipper: isWhiteBody ? CustomInvertedDTopBarClipper() : CustomDTopBarClipper(),
            child: isWhiteBody
                ? DeviceRoundedWhiteBodyInfo(
                    device: device,
                  )
                : DeviceTopBar(
                    device: device,
                    extent: adjustedShrinkOffset,
                    tailWidget: tailWidget,
                    onColorChanged: onColorChanged,
                    maxHeight: maxHeight,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => maxHeight; // isWhiteBody ? 300 : 350;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
}
