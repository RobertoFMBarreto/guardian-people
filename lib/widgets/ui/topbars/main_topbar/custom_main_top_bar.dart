import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/ui/topbars/main_topbar/extended_top_bar.dart';
import 'package:guardian/widgets/ui/topbars/main_topbar/normal_top_bar.dart';

/// Class that represents the main top abr body
//ignore: must_be_immutable
class CustomMainTopBar extends StatelessWidget {
  double extent;
  String name;
  String imageUrl;
  Widget? leadingWidget;
  Widget? tailWidget;
  double maxHeight;
  CustomMainTopBar({
    required this.extent,
    required this.name,
    required this.imageUrl,
    required this.maxHeight,
    this.leadingWidget,
    this.tailWidget,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
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
          ? NormalTopBar(
              name: name,
            )
          : ExtendedTopBar(
              extent: extent,
              name: name,
              imageUrl: imageUrl,
              leadingWidget: leadingWidget,
              tailWidget: tailWidget,
            ),
    );
  }
}
