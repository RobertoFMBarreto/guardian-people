import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';

/// Class that represents an icon with text widget
class IconText extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double? iconSize;
  final double? fontSize;
  final String text;
  final bool isInverted;
  final Color? textColor;
  const IconText({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
    this.iconSize,
    this.fontSize,
    this.textColor,
    this.isInverted = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color color = theme.brightness == Brightness.light && textColor == null
        ? gdTextColor
        : textColor == null
            ? gdDarkTextColor
            : textColor!;
    return isInverted
        ? Container(
            constraints: const BoxConstraints(maxWidth: 65, maxHeight: 17),
            child: Row(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
                      color: color,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 15,
                  ),
                ),
              ],
            ),
          )
        : Container(
            constraints: const BoxConstraints(maxWidth: 65, maxHeight: 17),
            child: Row(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: iconSize,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
