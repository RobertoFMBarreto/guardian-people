import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/activity_helper.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/widgets/ui/common/icon_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Class that represents a animal data with states list widget
class AnimalDataInfoList extends StatefulWidget {
  final List<AnimalLocationsCompanion> deviceData;
  final GlobalKey mapKey;
  const AnimalDataInfoList({super.key, required this.deviceData, required this.mapKey});

  @override
  State<AnimalDataInfoList> createState() => _AnimalDataInfoListState();
}

class _AnimalDataInfoListState extends State<AnimalDataInfoList> {
  late DateFormat _dateFormat;

  late int _currentTopicExtent;

  List<bool> animalDataInfo = [];
  List<bool> currentAnimalDataInfo = [];
  List<int> extensionsMade = [];
  @override
  void initState() {
    _currentTopicExtent = widget.deviceData.length < 10 ? widget.deviceData.length : 10;
    if (widget.deviceData.length == 1) {
      animalDataInfo.add(false);
    } else {
      animalDataInfo = widget.deviceData.map((e) => false).toList();
    }
    _dateFormat = DateFormat.Hms('PT');
    super.initState();
  }

  /// Method that allows to load 10 more items
  void getMoreInfo() {
    setState(() {
      int extensionSize = (_currentTopicExtent + 10) <= widget.deviceData.length
          ? 10
          : widget.deviceData.length - _currentTopicExtent;
      extensionsMade.add(extensionSize);
      animalDataInfo.addAll(
        List.generate(extensionSize, (index) => false),
      );

      _currentTopicExtent += extensionSize;
    });
  }

  /// Method taht allows to load 10 less items
  void showLessInfo() {
    setState(() {
      animalDataInfo.removeRange(
          widget.deviceData.length - extensionsMade.last, widget.deviceData.length);
      _currentTopicExtent -= extensionsMade.last;
    });
    extensionsMade.removeLast();
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
              animalDataInfo[panelIndex] = isExpanded;
            });
          },
          children: List.generate(_currentTopicExtent, (index) {
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
                        if (!isExpanded && widget.deviceData.length > 1)
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
                          // RichText(
                          //   text: TextSpan(
                          //     text: '${localizations.from_time.capitalizeFirst!} ',
                          //     style: theme.textTheme.bodyLarge,
                          //     children: [
                          //       TextSpan(
                          //         text: '${from.toString()}:00 ',
                          //         style: const TextStyle(fontWeight: FontWeight.bold),
                          //       ),
                          //       TextSpan(text: '${localizations.until_time} '),
                          //       TextSpan(
                          //         text: '${to.toString()}:00 ',
                          //         style: const TextStyle(fontWeight: FontWeight.bold),
                          //       ),
                          //       TextSpan(text: '${localizations.was} '),
                          //       TextSpan(
                          //         text: states[Random().nextInt(states.length)],
                          //         // widget.deviceData[index].state
                          //         //     .toShortString(context)
                          //         //     .capitalizeFirst!,
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           color: theme.colorScheme.secondary,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          RichText(
                            text: TextSpan(
                              text: '${localizations.at.capitalizeFirst!} ',
                              style: theme.textTheme.bodyLarge,
                              children: [
                                TextSpan(
                                  text:
                                      '${_dateFormat.format(widget.deviceData[index].date.value)} ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text:
                                        '${widget.deviceData[index].state.value != 'STANDING' && widget.deviceData[index].state.value != 'STILL' ? localizations.was : localizations.was_no_adjective} '),
                                TextSpan(
                                  text: activityToString(
                                      context, widget.deviceData[index].state.value!),
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
              body: widget.deviceData[index].temperature.value != null ||
                      widget.deviceData[index].battery.value != null ||
                      widget.deviceData[index].elevation.value != null
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconText(
                              icon: Icons.device_thermostat,
                              iconColor: theme.colorScheme.secondary,
                              text: '${widget.deviceData[index].temperature.value ?? 'N/A '}ºC',
                              fontSize: 15,
                              iconSize: 30,
                            ),
                            IconText(
                              icon: DeviceWidgetProvider.getBatteryIcon(
                                deviceBattery: widget.deviceData[index].battery.value,
                                color: theme.colorScheme.secondary,
                              ),
                              isInverted: true,
                              iconColor: theme.colorScheme.secondary,
                              text: '${widget.deviceData[index].battery.value ?? 'N/A '} %',
                              fontSize: 15,
                              iconSize: 30,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: IconText(
                            isInverted: true,
                            icon: Icons.landscape,
                            iconColor: theme.colorScheme.secondary,
                            text:
                                '${widget.deviceData[index].elevation.value != null ? widget.deviceData[index].elevation.value!.roundToDouble() : 'N/A '} m',
                            fontSize: 15,
                            iconSize: 30,
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: Text(
                        localizations.no_data_to_show.capitalizeFirst!,
                      ),
                    ),
            );
          }).toList(),
        ),
        if (widget.deviceData.length > 1 && _currentTopicExtent <= widget.deviceData.length)
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
              if (_currentTopicExtent < widget.deviceData.length)
                TextButton.icon(
                    onPressed: () {
                      getMoreInfo();
                    },
                    icon: Icon(Icons.add, color: theme.colorScheme.secondary),
                    label: Text(
                      '${localizations.load.capitalizeFirst!} ${localizations.more} ${(widget.deviceData.length - _currentTopicExtent) >= 10 ? 10 : widget.deviceData.length - _currentTopicExtent}',
                      style:
                          theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.secondary),
                    )),
            ],
          ),
      ],
    );
  }
}
