import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:guardian/colors.dart';

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
  Color pickedColor = gdMapGeofenceFillColor;
  @override
  void initState() {
    pickedColor = widget.pickerColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancelar',
            style: theme.textTheme.bodyLarge!.copyWith(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(pickedColor);
            Navigator.of(context).pop();
          },
          child: Text(
            'Guardar',
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
            pickerColor: pickedColor,
            onColorChanged: (color) {
              setState(() {
                pickedColor = color;
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
