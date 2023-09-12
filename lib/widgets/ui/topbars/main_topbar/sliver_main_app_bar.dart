import 'package:guardian/widgets/ui/topbars/main_topbar/path/custom_main_top_bar_wave_clipper.dart';
import 'package:guardian/widgets/ui/topbars/main_topbar/custom_main_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:guardian/widgets/ui/topbars/main_topbar/path/custom_s_top_bar_wave_clipper.dart';

class SliverMainAppBar extends SliverPersistentHeaderDelegate {
  Widget? leadingWidget;
  Widget? tailWidget;
  bool isHomeShape;
  Widget? title;
  String name;
  String imageUrl;
  double maxHeight;
  SliverMainAppBar({
    this.leadingWidget,
    this.tailWidget,
    this.title,
    required this.name,
    required this.imageUrl,
    required this.maxHeight,
    this.isHomeShape = false,
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
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
                child: title ?? const SizedBox(),
              ),
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
              maxHeight: maxHeight,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
}
