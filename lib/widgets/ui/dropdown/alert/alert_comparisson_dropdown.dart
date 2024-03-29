import 'package:flutter/material.dart';
import 'package:guardian/models/helpers/key_value_pair.dart';
import 'package:guardian/models/helpers/user_alert.dart';

/// Class that represents the alert comparisson dropdown widget
class AlertComparissonDropdown extends StatelessWidget {
  final AlertComparissons value;
  final List<KeyValuePair> values;
  final Function(Object?) onChanged;
  const AlertComparissonDropdown({
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
        border: Border.all(width: 1),
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
