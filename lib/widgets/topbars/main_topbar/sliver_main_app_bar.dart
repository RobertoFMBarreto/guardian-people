import 'package:guardian/widgets/topbars/main_topbar/path/custom_main_top_bar_wave_clipper.dart';
import 'package:guardian/widgets/topbars/main_topbar/custom_main_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:guardian/widgets/topbars/main_topbar/path/custom_s_top_bar_wave_clipper.dart';

class SliverMainAppBar extends SliverPersistentHeaderDelegate {
  Widget? leadingWidget;
  Widget? tailWidget;
  bool isHomeShape;
  Widget? title;
  String name;
  String imageUrl;
  SliverMainAppBar({
    this.leadingWidget,
    this.tailWidget,
    this.title,
    required this.name,
    required this.imageUrl,
    this.isHomeShape = false,
  });
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    var adjustedShrinkOffset = shrinkOffset > minExtent ? minExtent : shrinkOffset;

    return SizedBox(
      height: 300,
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
            clipper: isHomeShape ? CustomSTopBarWaveClipper() : CustomMainTopBarWaveClipper(),
            child: CustomMainTopBar(
              name: name,
              imageUrl: imageUrl,
              extent: adjustedShrinkOffset,
              leadingWidget: leadingWidget,
              tailWidget: tailWidget,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 300;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
}
