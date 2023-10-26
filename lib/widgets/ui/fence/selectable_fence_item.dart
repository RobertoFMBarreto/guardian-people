import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/settings/colors.dart';
import 'package:get/get.dart';
import 'package:guardian/widgets/ui/common/color_circle.dart';

/// Class that represents a selectable fence item widget
class SelectableFenceItem extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final Function() onSelected;
  const SelectableFenceItem({
    super.key,
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onSelected,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 35,
                color: gdSecondaryColor,
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      name,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            '${localizations.color.capitalize!}:',
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ColorCircle(
                          color: color,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
