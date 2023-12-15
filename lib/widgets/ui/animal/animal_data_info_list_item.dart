import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/widgets/ui/common/icon_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents a animal data with states list widget
class AnimalDataInfoList extends StatefulWidget {
  final List<AnimalLocationsCompanion> deviceData;
  final GlobalKey mapKey;
  const AnimalDataInfoList({super.key, required this.deviceData, required this.mapKey});

  @override
  State<AnimalDataInfoList> createState() => _AnimalDataInfoListState();
}

class _AnimalDataInfoListState extends State<AnimalDataInfoList> {
  int _currentTopicExtent = 10;
  List<bool> animalDataInfo = [];
  List<bool> currentAnimalDataInfo = [];
  List<String> states = ['Ruminar', 'Comer', 'Andar', 'Correr', 'Parada'];

  @override
  void initState() {
    if (widget.deviceData.length == 1) {
      animalDataInfo.add(false);
    } else {
      animalDataInfo = List.generate(10, (index) => false);
    }
    super.initState();
  }

  /// Method that allows to load 10 more items
  void getMoreInfo() {
    // TODO: code to get more 10 data info
    setState(() {
      animalDataInfo.addAll(List.generate(10, (index) => false));

      _currentTopicExtent += 10;
    });
  }

  /// Method taht allows to load 10 less items
  void showLessInfo() {
    // TODO: code to show less 10 data info
    setState(() {
      animalDataInfo.removeRange(10, _currentTopicExtent);
      _currentTopicExtent = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        ExpansionPanelList(
          dividerColor: Colors.transparent,
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              animalDataInfo[panelIndex] = !isExpanded;
            });
          },
          children: List.generate(animalDataInfo.length, (index) {
            int from = index + 1;
            int to = index + 2;

            return ExpansionPanel(
              isExpanded: animalDataInfo[index],
              canTapOnHeader: true,
              headerBuilder: (context, isExpanded) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        if (!isExpanded)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              height: 60,
                              width: 2,
                              decoration: const BoxDecoration(color: Colors.grey),
                            ),
                          ),
                        Icon(
                          Icons.radio_button_checked,
                          color: theme.colorScheme.secondary,
                          size: 30,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: '${localizations.from_time.capitalizeFirst!} ',
                              style: theme.textTheme.bodyLarge,
                              children: [
                                TextSpan(
                                  text: '${from.toString()}:00 ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: '${localizations.until_time} '),
                                TextSpan(
                                  text: '${to.toString()}:00 ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: '${localizations.was} '),
                                TextSpan(
                                  text: states[Random().nextInt(states.length)],
                                  // widget.deviceData[index].state
                                  //     .toShortString(context)
                                  //     .capitalizeFirst!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
              body: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconText(
                    icon: Icons.device_thermostat,
                    iconColor: theme.colorScheme.secondary,
                    text: '${widget.deviceData.first.temperature.value}ºC',
                    fontSize: 15,
                    iconSize: 30,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: IconText(
                          isInverted: true,
                          icon: Icons.landscape,
                          iconColor: theme.colorScheme.secondary,
                          text: '${widget.deviceData.first.elevation.value}m',
                          fontSize: 15,
                          iconSize: 30,
                        ),
                      ),
                      IconText(
                        icon: DeviceWidgetProvider.getBatteryIcon(
                          deviceBattery: 80,
                          color: theme.colorScheme.secondary,
                        ),
                        isInverted: true,
                        iconColor: theme.colorScheme.secondary,
                        text: '${widget.deviceData.first.battery.value}%',
                        fontSize: 15,
                        iconSize: 30,
                      ),
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        ),
        if (widget.deviceData.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentTopicExtent > 10)
                TextButton.icon(
                    onPressed: () {
                      showLessInfo();

                      Scrollable.ensureVisible(widget.mapKey.currentContext!,
                          duration: const Duration(seconds: 1));
                    },
                    icon: Icon(Icons.remove, color: theme.colorScheme.secondary),
                    label: Text(
                      localizations.hide.capitalizeFirst!,
                      style:
                          theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.secondary),
                    )),
              TextButton.icon(
                  onPressed: () {
                    getMoreInfo();
                  },
                  icon: Icon(Icons.add, color: theme.colorScheme.secondary),
                  label: Text(
                    '${localizations.load.capitalizeFirst!} ${localizations.more} ${(widget.deviceData.length - _currentTopicExtent) >= 10 ? 10 : widget.deviceData.length - _currentTopicExtent}',
                    style: theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.secondary),
                  )),
            ],
          ),
      ],
    );
  }
}
