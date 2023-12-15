import 'package:auto_size_text/auto_size_text.dart';
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
        ? FittedBox(
            fit: BoxFit.fitHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  text,
                  maxFontSize: fontSize!,
                  minFontSize: 1,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color,
                    fontSize: fontSize,
                  ),
                ),
                Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
              ],
            ),
          )
        : FittedBox(
            fit: BoxFit.fitWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
                AutoSizeText(
                  text,
                  maxFontSize: fontSize!,
                  minFontSize: 1,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          );
  }
}
