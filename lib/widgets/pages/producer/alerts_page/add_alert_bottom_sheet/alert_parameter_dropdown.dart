import 'package:flutter/material.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';

class AlertParameterDropdown extends StatelessWidget {
  final AlertParameter value;
  final Function(AlertParameter?) onChanged;
  const AlertParameterDropdown({super.key, required this.value, required this.onChanged});

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
              value: AlertParameter.battery,
              child: Text(
                'Bateria',
              ),
            ),
            DropdownMenuItem(
              value: AlertParameter.dataUsage,
              child: Text(
                'Utilização de dados',
              ),
            ),
            DropdownMenuItem(
              value: AlertParameter.temperature,
              child: Text(
                'Temperatura',
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
