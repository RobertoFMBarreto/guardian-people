import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:guardian/settings/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';

/// Class that represents the custom color picker input widget
class CustomColorPickerInput extends StatefulWidget {
  final Color pickerColor;
  final String hexColor;
  final Function(Color) onSave;
  const CustomColorPickerInput(
      {super.key, required this.pickerColor, required this.hexColor, required this.onSave});

  @override
  State<CustomColorPickerInput> createState() => _CustomColorPickerInputState();
}

class _CustomColorPickerInputState extends State<CustomColorPickerInput> {
  Color _pickedColor = gdMapGeofenceFillColor;
  @override
  void initState() {
    _pickedColor = widget.pickerColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            localizations.cancel.capitalize(),
            style: theme.textTheme.bodyLarge!.copyWith(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_pickedColor);
            Navigator.of(context).pop();
          },
          child: Text(
            localizations.confirm.capitalize(),
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorPicker(
            pickerColor: _pickedColor,
            colorPickerWidth: 300,
            onColorChanged: (color) {
              setState(() {
                _pickedColor = color;
              });
            },
            showLabel: false,
            enableAlpha: false,
          ),
          Text(
            widget.hexColor,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
