import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double fontSize;
  final String text;
  final bool isInverted;
  final Color? textColor;
  const IconText({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.iconSize,
    required this.fontSize,
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
        ? Row(
            children: [
              Text(
                text,
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize,
                  color: color,
                ),
              ),
              Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
            ],
          )
        : Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
              Text(
                text,
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize,
                  color: color,
                ),
              ),
            ],
          );
  }
}
