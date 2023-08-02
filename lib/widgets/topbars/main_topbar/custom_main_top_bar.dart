import 'package:flutter/material.dart';
import 'package:guardian/widgets/topbars/main_topbar/extended_top_bar.dart';
import 'package:guardian/widgets/topbars/main_topbar/normal_top_bar.dart';

class CustomMainTopBar extends StatelessWidget {
  double extent;
  String name;
  String imageUrl;
  Widget? leadingWidget;
  Widget? tailWidget;
  CustomMainTopBar({
    required this.extent,
    required this.name,
    required this.imageUrl,
    this.leadingWidget,
    this.tailWidget,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
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
