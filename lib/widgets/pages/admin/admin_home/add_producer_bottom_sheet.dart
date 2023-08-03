import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/models/focus_manager.dart';
import 'package:guardian/widgets/default_bottom_sheet.dart';

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
    return DefaultBottomSheet(
      title: 'Adicionar Produtor',
      body: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 20.0),
          child: TextField(
            decoration: InputDecoration(
              label: Text('Nome'),
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
                  'Cancelar',
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
                  'Adicionar',
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