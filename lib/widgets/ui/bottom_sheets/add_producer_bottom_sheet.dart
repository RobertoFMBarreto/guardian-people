import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/widgets/ui/bottom_sheets/default_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the add producer bottom sheet widget
class AddProducerBottomSheet extends StatefulWidget {
  final Function()? onAddProducer;
  const AddProducerBottomSheet({super.key, this.onAddProducer});

  @override
  State<AddProducerBottomSheet> createState() => _AddProducerBottomSheetState();
}

class _AddProducerBottomSheetState extends State<AddProducerBottomSheet> {
  String producerName = '';
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return DefaultBottomSheet(
      title: '${localizations.add.capitalizeFirst!} ${localizations.producer}',
      body: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 20.0),
          child: TextField(
            decoration: InputDecoration(
              label: Text(localizations.name.capitalizeFirst!),
            ),
            onChanged: (value) {
              producerName = value;
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
                  localizations.cancel.capitalizeFirst!,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: deviceWidth * 0.05,
              ),
              ElevatedButton(
                onPressed: widget.onAddProducer,
                child: Text(
                  localizations.add.capitalizeFirst!,
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
