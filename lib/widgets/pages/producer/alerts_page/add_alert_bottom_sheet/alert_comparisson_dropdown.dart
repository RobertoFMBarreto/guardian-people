import 'package:flutter/material.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';

class AlertComparissonDropdown extends StatelessWidget {
  final AlertComparissons value;
  final Function(AlertComparissons?) onChanged;
  const AlertComparissonDropdown({super.key, required this.value, required this.onChanged});

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
            items: const [
              DropdownMenuItem(
                value: AlertComparissons.equal,
                child: Text(
                  'Igual',
                ),
              ),
              DropdownMenuItem(
                value: AlertComparissons.greater,
                child: Text(
                  'Maior',
                ),
              ),
              DropdownMenuItem(
                value: AlertComparissons.less,
                child: Text(
                  'Menor',
                ),
              ),
              DropdownMenuItem(
                value: AlertComparissons.greaterOrEqual,
                child: Text(
                  'Maior ou igual',
                ),
              ),
              DropdownMenuItem(
                value: AlertComparissons.lessOrEqual,
                child: Text(
                  'Menor ou igual',
                ),
              ),
            ],
            onChanged: onChanged),
      ),
    );
  }
}
