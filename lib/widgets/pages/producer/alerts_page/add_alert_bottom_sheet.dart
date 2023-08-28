import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/widgets/default_bottom_sheet.dart';
import 'package:guardian/widgets/pages/producer/alerts_page/add_alert_bottom_sheet/alert_comparisson_dropdown.dart';
import 'package:guardian/widgets/pages/producer/alerts_page/add_alert_bottom_sheet/alert_parameter_dropdown.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddAlertBottomSheet extends StatefulWidget {
  final Function(
    AlertParameter parameter,
    AlertComparissons comparisson,
    double value,
    bool hasNotification,
  ) onConfirm;
  final AlertParameter? parameter;
  final AlertComparissons? comparisson;
  final double? value;
  final bool? hasNotification;
  final bool? isEdit;
  const AddAlertBottomSheet({
    super.key,
    required this.onConfirm,
    this.parameter,
    this.comparisson,
    this.value,
    this.hasNotification,
    this.isEdit = false,
  });

  @override
  State<AddAlertBottomSheet> createState() => _AddAlertBottomSheetState();
}

class _AddAlertBottomSheetState extends State<AddAlertBottomSheet> {
  AlertComparissons alertComparisson = AlertComparissons.equal;
  AlertParameter alertParameter = AlertParameter.temperature;
  double comparissonValue = 0;
  bool sendNotification = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.comparisson != null) alertComparisson = widget.comparisson!;
    if (widget.parameter != null) alertParameter = widget.parameter!;
    if (widget.value != null) comparissonValue = widget.value!;
    if (widget.hasNotification != null) sendNotification = widget.hasNotification!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return DefaultBottomSheet(
      title:
          '${widget.isEdit! ? localizations.edit.capitalize() : localizations.add.capitalize()} ${localizations.warnings.capitalize()}',
      bodyCrossAxisAlignment: CrossAxisAlignment.start,
      body: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.when.capitalize(),
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: AlertParameterDropdown(
                  value: alertParameter,
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        alertParameter = value;
                      }
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AlertComparissonDropdown(
                    value: alertComparisson,
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          alertComparisson = value;
                        }
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      localizations.to,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        label: Text(localizations.value.capitalize()),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: comparissonValue != 0 ? comparissonValue.toString() : null,
                      validator: (value) {
                        if (value == null) {
                          return localizations.insert_value.capitalize();
                        } else {
                          double? inputValue = double.tryParse(value);
                          if (inputValue != null) {
                            switch (alertParameter) {
                              case AlertParameter.battery:
                                if (inputValue < 0 || inputValue > 100) {
                                  return localizations.invalid_value.capitalize();
                                }
                                break;
                              case AlertParameter.dataUsage:
                                if (inputValue < 0 || inputValue > 10) {
                                  return localizations.invalid_value.capitalize();
                                }
                                break;
                              case AlertParameter.temperature:
                                break;
                            }
                          } else {
                            return localizations.invalid_value.capitalize();
                          }
                          return null;
                        }
                      },
                      onChanged: (value) {
                        double? inputValue = double.tryParse(value);
                        if (inputValue != null) {
                          comparissonValue = inputValue;
                        }
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  localizations.what_to_do.capitalize(),
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Text(
                      '${localizations.send.capitalize()} ${localizations.notification.capitalize()}:',
                      style: theme.textTheme.bodyLarge,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Switch(
                          activeTrackColor: theme.colorScheme.secondary,
                          value: sendNotification,
                          onChanged: (value) {
                            setState(() {
                              sendNotification = value;
                            });
                          }),
                    ),
                  ],
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
                        if (_formKey.currentState!.validate()) {
                          widget.onConfirm(
                            alertParameter,
                            alertComparisson,
                            comparissonValue,
                            sendNotification,
                          );
                        }
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}
