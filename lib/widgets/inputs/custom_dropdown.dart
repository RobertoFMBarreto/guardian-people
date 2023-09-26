import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/helpers/key_value_pair.dart';

/// Class that represents the custom dropdown widget
class CustomDropdown extends StatelessWidget {
  final Object value;
  final List<KeyValuePair> values;
  final Function(Object?) onChanged;
  const CustomDropdown({
    super.key,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          width: 1,
          color: gdInputTextBorderColors,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: DropdownButton(
          isDense: true,
          borderRadius: BorderRadius.circular(20),
          underline: const SizedBox(),
          value: value,
          items: [
            ...values
                .map(
                  (e) => DropdownMenuItem(
                    value: e.value,
                    child: Text(e.key),
                  ),
                )
                .toList()
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
