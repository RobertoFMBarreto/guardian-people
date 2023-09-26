import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/translator/animals_translator.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/ui/device/device_item.dart';
import 'package:guardian/widgets/ui/device/device_item_selectable.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';

import '../../../widgets/ui/drawers/producer_page_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProducerDevicesPage extends StatefulWidget {
  final bool isSelect;
  final BigInt? idFence;
  final BigInt? idAlert;
  final List<BigInt>? notToShowAnimals;

  const ProducerDevicesPage({
    super.key,
    this.isSelect = false,
    this.idFence,
    this.idAlert,
    this.notToShowAnimals,
  });

  @override
  State<ProducerDevicesPage> createState() => _ProducerDevicesPageState();
}

class _ProducerDevicesPageState extends State<ProducerDevicesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late double _maxElevation;
  late double _maxTemperature;
  late Future<void> _future;

  String _searchString = '';
  RangeValues _batteryRangeValues = const RangeValues(0, 100);
  RangeValues _dtUsageRangeValues = const RangeValues(0, 10);
  RangeValues _elevationRangeValues = const RangeValues(0, 1000);
  RangeValues _tmpRangeValues = const RangeValues(0, 25);

  List<Animal> _selectedDevices = [];
  List<Animal> _animals = [];

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  Future<void> _setup() async {
    await _setupFilterRanges();
    await _filterDevices();
    await _getDevicesFromApi();
  }

  Future<void> _setupFilterRanges() async {
    _batteryRangeValues = const RangeValues(0, 100);
    _dtUsageRangeValues = const RangeValues(0, 10);

    _maxElevation = await getMaxElevation();
    _maxTemperature = await getMaxTemperature();
    if (mounted) {
      setState(() {
        _elevationRangeValues = RangeValues(0, _maxElevation);
        _tmpRangeValues = RangeValues(0, _maxTemperature);
      });
    }
  }

  Future<void> _resetFilters() async {
    if (mounted) {
      setState(() {
        _batteryRangeValues = const RangeValues(0, 100);
        _dtUsageRangeValues = const RangeValues(0, 10);
        _elevationRangeValues = RangeValues(0, _maxTemperature);
        _tmpRangeValues = RangeValues(0, _maxElevation);
      });
    }
  }

  Future<void> _getDevicesFromApi() async {
    AnimalProvider.getAnimals().then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        await animalsFromJson(response.body);
        await _filterDevices();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken);
            _getDevicesFromApi();
          } else if (response.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            setShownNoServerConnection(true).then(
              (_) =>
                  showDialog(context: context, builder: (context) => const ServerErrorDialogue()),
            );
          }
        });
      }
    });
  }

  Future<void> _filterDevices() async {
    if (widget.isSelect && widget.idFence != null) {
      await getUserFenceUnselectedAnimalsFiltered(
        batteryRangeValues: _batteryRangeValues,
        elevationRangeValues: _elevationRangeValues,
        dtUsageRangeValues: _dtUsageRangeValues,
        searchString: _searchString,
        tmpRangeValues: _tmpRangeValues,
        idFence: widget.idFence!,
      ).then((searchDevices) {
        if (mounted) {
          setState(() {
            _animals = [];
            _animals.addAll(searchDevices);
          });
        }
      });
    } else {
      getUserAnimalsFiltered(
        batteryRangeValues: _batteryRangeValues,
        elevationRangeValues: _elevationRangeValues,
        dtUsageRangeValues: _dtUsageRangeValues,
        searchString: _searchString,
        tmpRangeValues: _tmpRangeValues,
      ).then(
        (filteredDevices) => setState(() {
          _animals = [];
          if (widget.notToShowAnimals != null) {
            _animals.addAll(
              filteredDevices.where(
                (device) => !widget.notToShowAnimals!.contains(
                  device.animal.idAnimal.value,
                ),
              ),
            );
          } else {
            _animals.addAll(filteredDevices);
          }
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return GestureDetector(
        onTap: () {
          CustomFocusManager.unfocus(context);
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              localizations.devices.capitalize(),
              style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
          ),
          endDrawer: _animals.isNotEmpty
              ? SafeArea(
                  child: ProducerPageDrawer(
                    batteryRangeValues: _batteryRangeValues,
                    dtUsageRangeValues: _dtUsageRangeValues,
                    tmpRangeValues: _tmpRangeValues,
                    elevationRangeValues: _elevationRangeValues,
                    maxElevation: _maxElevation,
                    maxTemp: _maxTemperature,
                    onChangedBat: (values) {
                      setState(() {
                        _batteryRangeValues = values;
                      });
                    },
                    onChangedDtUsg: (values) {
                      setState(() {
                        _dtUsageRangeValues = values;
                      });
                    },
                    onChangedTmp: (values) {
                      setState(() {
                        _tmpRangeValues = values;
                      });
                    },
                    onChangedElev: (values) {
                      setState(() {
                        _elevationRangeValues = values;
                      });
                    },
                    onConfirm: () {
                      _filterDevices();
                      _scaffoldKey.currentState!.closeEndDrawer();
                    },
                    onResetFilters: () {
                      _resetFilters();
                      _filterDevices();
                    },
                  ),
                )
              : null,
          floatingActionButton: widget.isSelect && _selectedDevices.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedDevices);
                  },
                  label: Text(
                    localizations.confirm.capitalize(),
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  icon: const Icon(Icons.done),
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                )
              : null,
          body: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomCircularProgressIndicator();
                } else {
                  return SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                          child: SearchWithFilterInput(
                            onFilter: () {
                              _scaffoldKey.currentState!.openEndDrawer();
                            },
                            onSearchChanged: (value) {
                              _searchString = value;
                              _filterDevices();
                            },
                          ),
                        ),
                        if (widget.isSelect)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (_selectedDevices.length == _animals.length) {
                                    setState(() {
                                      _selectedDevices = [];
                                    });
                                  } else {
                                    setState(() {
                                      _selectedDevices = _animals;
                                    });
                                  }
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedDevices.length == _animals.length
                                          ? Icons.remove
                                          : Icons.add,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    Text(
                                      localizations.select_all.capitalize(),
                                      style: theme.textTheme.bodyLarge!.copyWith(
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        Expanded(
                          child: _animals.isEmpty
                              ? Center(
                                  child: Text(localizations.no_devices.capitalize()),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: ListView.builder(
                                    itemCount: _animals.length,
                                    itemBuilder: (context, index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: widget.isSelect
                                          ? DeviceItemSelectable(
                                              deviceImei: _animals[index].animal.animalName.value,
                                              deviceData: _animals[index].data.isNotEmpty
                                                  ? _animals[index].data.first.dataUsage.value
                                                  : null,
                                              deviceBattery: _animals[index].data.isNotEmpty
                                                  ? _animals[index].data.first.battery.value
                                                  : null,
                                              isSelected: _selectedDevices
                                                  .where((element) =>
                                                      element.animal.idAnimal ==
                                                      _animals[index].animal.idAnimal)
                                                  .isNotEmpty,
                                              onSelected: () {
                                                int i = _selectedDevices.indexWhere((element) =>
                                                    element.animal.idAnimal ==
                                                    _animals[index].animal.idAnimal);

                                                if (mounted) {
                                                  setState(() {
                                                    if (i >= 0) {
                                                      _selectedDevices.removeAt(i);
                                                    } else {
                                                      _selectedDevices.add(_animals[index]);
                                                    }
                                                  });
                                                }
                                              },
                                            )
                                          : DeviceItem(
                                              animal: _animals[index],
                                              onBackFromDeviceScreen: () {
                                                _filterDevices();
                                              },
                                            ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                }
              }),
        ));
  }
}
