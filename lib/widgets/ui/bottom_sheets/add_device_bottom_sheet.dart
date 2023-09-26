import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/widgets/ui/bottom_sheets/default_bottom_sheet.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddDeviceBottomSheet extends StatefulWidget {
  final Function(String, String) onAddDevice;
  const AddDeviceBottomSheet({super.key, required this.onAddDevice});

  @override
  State<AddDeviceBottomSheet> createState() => _AddDeviceBottomSheetState();
}

class _AddDeviceBottomSheetState extends State<AddDeviceBottomSheet> {
  String _imei = '';
  String _name = '';
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return DefaultBottomSheet(
      title: '${localizations.add.capitalize()} ${localizations.device.capitalize()}',
      body: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 20.0),
          child: TextField(
            decoration: const InputDecoration(
              label: Text('IMEI'),
            ),
            onChanged: (value) {
              _imei = value;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 20.0),
          child: TextField(
            decoration: InputDecoration(
              label: Text(localizations.name.capitalize()),
            ),
            onChanged: (value) {
              _name = value;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  CustomFocusManager.unfocus(context);
                  Navigator.of(context).pop();
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(gdCancelBtnColor),
                ),
                child: Text(
                  localizations.cancel.capitalize(),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: deviceWidth * 0.05,
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onAddDevice(_imei, _name);
                },
                child: Text(
                  localizations.add.capitalize(),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
