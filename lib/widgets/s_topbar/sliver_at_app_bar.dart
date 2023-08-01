import 'package:august_testing/widgets/s_topbar/path/custom_s_top_bar_wave_clipper.dart';
import 'package:august_testing/widgets/s_topbar/custom_s_top_bar.dart';
import 'package:flutter/material.dart';

class SliverATAppBar extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    var adjustedShrinkOffset = shrinkOffset > minExtent ? minExtent : shrinkOffset;
    return SizedBox(
      height: 300,
      child: ClipPath(
        clipper: CustomSTopBarWaveClipper(),
        child: CustomSTopBar(extent: adjustedShrinkOffset),
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
