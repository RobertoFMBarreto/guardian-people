import 'package:flutter/material.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/key_value_pair.dart';

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
            // DropdownMenuItem(
            //   value: AlertComparissons.equal,
            //   child: Text(
            //     'Igual',
            //   ),
            // ),
            // DropdownMenuItem(
            //   value: AlertComparissons.greater,
            //   child: Text(
            //     'Maior',
            //   ),
            // ),
            // DropdownMenuItem(
            //   value: AlertComparissons.less,
            //   child: Text(
            //     'Menor',
            //   ),
            // ),
            // DropdownMenuItem(
            //   value: AlertComparissons.greaterOrEqual,
            //   child: Text(
            //     'Maior ou igual',
            //   ),
            // ),
            // DropdownMenuItem(
            //   value: AlertComparissons.lessOrEqual,
            //   child: Text(
            //     'Menor ou igual',
            //   ),
            // ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
