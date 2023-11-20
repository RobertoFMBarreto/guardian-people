import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/widgets/ui/animal/animal_map_widget.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/sliver_device_app_bar.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Method that represents the device page
class AnimalPage extends StatefulWidget {
  final Animal animal;

  const AnimalPage({
    super.key,
    required this.animal,
  });

  @override
  State<AnimalPage> createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  bool _isInterval = false;
  late Animal _animal;
  int _reloadNum = 0;
  @override
  void initState() {
    _animal = widget.animal;

    super.initState();
  }

  /// Method that allows to update animal on api
  Future<void> _updateAnimal(String newColor) async {
    setState(() {
      _animal = Animal(
          animal: _animal.animal.copyWith(animalColor: drift.Value(newColor)), data: _animal.data);
    });
    AnimalRequests.updateAnimal(
      animal: _animal,
      context: context,
      onFailed: () {
        AppLocalizations localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(localizations.server_error)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: _isInterval
          ? AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? gdGradientEnd
                  : gdDarkGradientEnd,
              title: Text(widget.animal.animal.animalName.value),
              foregroundColor: Colors.white,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: theme.colorScheme.onSecondary,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(
                      '/producer/device/settings',
                      arguments: _animal,
                    )
                        .then((newDevice) {
                      if (newDevice != null && newDevice.runtimeType == Animal) {
                        setState(() => _animal = (newDevice as Animal));
                      } else {
                        // Force reload map
                        setState(() {
                          _reloadNum = Random().nextInt(999999);
                        });
                      }
                    });
                  },
                )
              ],
            )
          : AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? gdGradientEnd
                  : gdDarkGradientEnd,
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            CustomPageRouter(
                page: '/producer/device/history',
                settings: RouteSettings(
                  arguments: widget.animal,
                )),
          );
        },
        backgroundColor: theme.colorScheme.secondary,
        label: Text(
          localizations.state_history.capitalizeFirst!,
          style: theme.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            if (!_isInterval)
              SliverPersistentHeader(
                key: Key("${_animal.animal.animalName.value}$hasConnection${theme.brightness}"),
                pinned: true,
                delegate: SliverDeviceAppBar(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                  onColorChanged: _updateAnimal,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            localizations.localization.capitalizeFirst!,
                            style: theme.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ToggleSwitch(
                          initialLabelIndex: _isInterval ? 1 : 0,
                          cornerRadius: 50,
                          radiusStyle: true,
                          activeBgColor: [theme.colorScheme.secondary],
                          activeFgColor: theme.colorScheme.onSecondary,
                          inactiveBgColor: Theme.of(context).brightness == Brightness.light
                              ? gdToggleGreyArea
                              : gdDarkToggleGreyArea,
                          inactiveFgColor: Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                          customTextStyles: const [
                            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                          ],
                          totalSwitches: 2,
                          labels: [
                            localizations.current.capitalizeFirst!,
                            localizations.range.capitalizeFirst!,
                          ],
                          onToggle: (index) {
                            setState(() {
                              _isInterval = index == 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  device: _animal,
                  leadingWidget: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSecondary,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  tailWidget: hasConnection
                      ? IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: theme.colorScheme.onSecondary,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(
                              '/producer/device/settings',
                              arguments: _animal,
                            )
                                .then((newDevice) {
                              if (newDevice != null && newDevice.runtimeType == Animal) {
                                setState(() => _animal = (newDevice as Animal));
                              } else {
                                // Force reload map
                                setState(() {
                                  _reloadNum = Random().nextInt(999999);
                                });
                              }
                            });
                          },
                        )
                      : null,
                ),
              ),
            SliverFillRemaining(
              child: Column(
                children: [
                  if (_isInterval)
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              localizations.localization.capitalizeFirst!,
                              style: theme.textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ToggleSwitch(
                            initialLabelIndex: _isInterval ? 1 : 0,
                            cornerRadius: 50,
                            radiusStyle: true,
                            activeBgColor: [theme.colorScheme.secondary],
                            activeFgColor: theme.colorScheme.onSecondary,
                            inactiveBgColor: Theme.of(context).brightness == Brightness.light
                                ? gdToggleGreyArea
                                : gdDarkToggleGreyArea,
                            inactiveFgColor: Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                            customTextStyles: const [
                              TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                              TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                            ],
                            totalSwitches: 2,
                            labels: [
                              localizations.current.capitalizeFirst!,
                              localizations.range.capitalizeFirst!,
                            ],
                            onToggle: (index) {
                              setState(() {
                                _isInterval = index == 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: AnimalMapWidget(
                      key: Key('$_reloadNum'),
                      animal: _animal,
                      isInterval: _isInterval,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
