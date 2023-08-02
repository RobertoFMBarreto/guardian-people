import 'package:flutter/material.dart';

class ExtendedTopBar extends StatelessWidget {
  double extent;
  String name;
  String imageUrl;
  Widget? leadingWidget;
  Widget? tailWidget;
  ExtendedTopBar({
    required this.extent,
    required this.name,
    required this.imageUrl,
    this.leadingWidget,
    this.tailWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return FittedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: deviceWidth,
            child: Row(
              mainAxisAlignment: leadingWidget != null && tailWidget != null
                  ? MainAxisAlignment.spaceBetween
                  : leadingWidget != null
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
              children: [
                leadingWidget ?? const SizedBox(),
                tailWidget ?? const SizedBox(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 60 * (1 - (extent / 100)),
            ),
          ),
          Text(
            name,
            style: theme.textTheme.headlineMedium!.copyWith(color: theme.colorScheme.onSecondary),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: deviceHeight * 0.08,
            ),
          )
        ],
      ),
    );
  }
}
