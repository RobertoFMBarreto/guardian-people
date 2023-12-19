import 'package:flutter/material.dart';
import 'package:guardian/widgets/ui/user/circle_avatar_border.dart';

/// Class that represenst the extended top bar body
//ignore: must_be_immutable
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
    return Column(
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
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CircleAvatarBorder(
                  radius: (deviceHeight * 0.06) * (1 - (extent / 100)),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  style: theme.textTheme.headlineMedium!
                      .copyWith(color: theme.colorScheme.onSecondary),
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: deviceHeight * 0.08))
            ],
          ),
        ),
      ],
    );
  }
}
