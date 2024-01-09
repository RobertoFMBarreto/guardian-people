import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/ui/animal/animal_item.dart';
import 'package:guardian/widgets/ui/animal/animal_item_selectable.dart';

import '../../../widgets/ui/drawers/producer_page_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the producer devices page
class ProducerAnimalsPage extends StatefulWidget {
  final bool isSelect;
  final String? idFence;
  final String? idAlert;
  final List<String>? notToShowAnimals;

  const ProducerAnimalsPage({
    super.key,
    this.isSelect = false,
    this.idFence,
    this.idAlert,
    this.notToShowAnimals,
  });

  @override
  State<ProducerAnimalsPage> createState() => _ProducerAnimalsPageState();
}

class _ProducerAnimalsPageState extends State<ProducerAnimalsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late double _maxElevation;
  late double _maxTemperature;
  late Future<void> _future;

  late StreamSubscription<BluetoothConnectionState> subscription;
  late BluetoothDevice device;

  String _searchString = '';
  bool _firstRun = true;
  RangeValues _batteryRangeValues = const RangeValues(0, 100);
  RangeValues _dtUsageRangeValues = const RangeValues(0, 10);
  RangeValues _elevationRangeValues = const RangeValues(0, 1000);
  RangeValues _tmpRangeValues = const RangeValues(0, 25);

  List<Animal> _selectedAnimals = [];
  List<Animal> _animals = [];

  @override
  void dispose() {
    if (device.isConnected) {
      device.disconnect();
    }
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  /// Method that does the initial setup for the page
  ///
  /// 1. setup all filters
  /// 2. filter the animals to load all local animals
  /// 3. get the animals from the api
  Future<void> _setup() async {
    isSnackbarActive = false;
    await _setupFilterRanges();
    await _filterAnimals();
    await _getAnimalsFromApi();
    print('Devices');

    await FlutterBluePlus.startScan(
      timeout: Duration(seconds: 4),
      withServices: [
        Guid.fromString('6E400001-B5A3-F393-E0A9-E50E24DCCA9E'),
        Guid.fromString('6E400003-B5A3-F393-E0A9-E50E24DCCA9E'),
      ],
    );

    FlutterBluePlus.onScanResults.listen((results) async {
      for (ScanResult res in results) {
        print("[BT][Connectiong] - Connecting to device: ${res.device.remoteId}");
        device = res.device;

        // listen for disconnection
        subscription = device.connectionState.listen((BluetoothConnectionState state) async {
          if (state == BluetoothConnectionState.disconnected) {
            // 1. typically, start a periodic timer that tries to
            //    reconnect, or just call connect() again right now
            // 2. you must always re-discover services after disconnection!
            print(
                "[BT][STOP] - ${device.disconnectReason?.code} ${device.disconnectReason?.description}");
          }
        });
        await device.connect();

        final services = await res.device.discoverServices();
        for (BluetoothService service in services) {
          print('[BT][Service] - Service: $service');
          if (service.serviceUuid == Guid.fromString('6E400001-B5A3-F393-E0A9-E50E24DCCA9E')) {
            final characteristics = service.characteristics;
            for (BluetoothCharacteristic characteristic in characteristics) {
              print('[BT][Characteristic] - Characteristic: ${characteristic.characteristicUuid}');
              if (characteristic.characteristicUuid ==
                  Guid.fromString('6e400003-b5a3-f393-e0a9-e50e24dcca9e')) {
                final characteristicSubscription = characteristic.onValueReceived.listen((payload) {
                  print("[BT][Payload] - ${payload}");
                  String data = String.fromCharCodes(payload
                      .toList()
                      .getRange(0, payload.length)
                      .join(',')
                      .split(',')
                      .map(int.parse));
                  print("[BT][DATA] - ${data}");

                  connectToSocket(data);
                });
                device.cancelWhenDisconnected(characteristicSubscription);
                await characteristic.setNotifyValue(true);
              }
            }
          }
        }
      }
    });
  }

  void connectToSocket(String toSend) {
    var addressesIListenFrom = InternetAddress.anyIPv4;
    int portIListenOn = 16123; //0 is random
    RawDatagramSocket.bind(addressesIListenFrom, portIListenOn).then((RawDatagramSocket udpSocket) {
      udpSocket.forEach((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = udpSocket.receive();
          if (dg != null) dg.data.forEach((x) => print(x));
        }
      });
      udpSocket.send('af333530343537373930373335383437102262731323334353637681'.codeUnits,
          InternetAddress('77.54.1.149'), 47659);
      print('Did send data on the stream..');
    });
  }

  /// Method that does the setup of filters based on de database values
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

  /// Method that resets all filters to the initial values
  Future<void> _resetFilters() async {
    if (mounted) {
      setState(() {
        _batteryRangeValues = const RangeValues(0, 100);
        _dtUsageRangeValues = const RangeValues(0, 10);
        _elevationRangeValues = RangeValues(0, _maxElevation);
        _tmpRangeValues = RangeValues(0, _maxTemperature);
      });
    }
  }

  /// Method that loads all devices from the API into the [_animals] list
  ///
  /// In case the session token expires then it calls the api to refresh the token and doest the initial request again
  ///
  /// If the server takes too long to answer then the user receives and alert
  Future<void> _getAnimalsFromApi() async {
    AnimalRequests.getAnimalsFromApiWithLastLocation(
        context: context,
        onFailed: (statusCode) {
          if (!hasConnection && !isSnackbarActive) {
            showNoConnectionSnackBar();
          } else {
            if (statusCode == 507 || statusCode == 404) {
              if (_firstRun == true) {
                showNoConnectionSnackBar();
              }
              _firstRun = false;
            } else if (!isSnackbarActive) {
              AppLocalizations localizations = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(localizations.server_error)));
            }
          }
        },
        onDataGotten: () {
          _filterAnimals();
        });
  }

  /// Method that filters all animals loading them into the [_animals] list
  ///
  /// If in select mode it only loads the animals that aren't selected for the fence or the alert
  ///
  /// If not in select mode it loads all the animals
  ///
  /// Resets the [_animals] list to prevent duplicates
  Future<void> _filterAnimals() async {
    if (widget.isSelect && widget.idFence != null) {
      await getUserFenceUnselectedAnimalsFiltered(
        batteryRangeValues: _batteryRangeValues,
        elevationRangeValues: _elevationRangeValues,
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
    } else if (widget.isSelect && widget.idAlert != null) {
      await getUserAlertUnselectedAnimalsFiltered(
        batteryRangeValues: _batteryRangeValues,
        elevationRangeValues: _elevationRangeValues,
        dtUsageRangeValues: _dtUsageRangeValues,
        searchString: _searchString,
        tmpRangeValues: _tmpRangeValues,
        idAlert: widget.idAlert!,
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
              localizations.devices.capitalizeFirst!,
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
                      _filterAnimals();
                      _scaffoldKey.currentState!.closeEndDrawer();
                    },
                    onResetFilters: () {
                      _resetFilters();
                      _filterAnimals();
                    },
                  ),
                )
              : null,
          floatingActionButton: widget.isSelect && _selectedAnimals.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedAnimals);
                  },
                  label: Text(
                    localizations.confirm.capitalizeFirst!,
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
                              _filterAnimals();
                            },
                          ),
                        ),
                        if (widget.isSelect)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (_selectedAnimals.length == _animals.length) {
                                    setState(() {
                                      _selectedAnimals = [];
                                    });
                                  } else {
                                    setState(() {
                                      _selectedAnimals = _animals;
                                    });
                                  }
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedAnimals.length == _animals.length
                                          ? Icons.remove
                                          : Icons.add,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    Text(
                                      localizations.select_all.capitalizeFirst!,
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
                                  child: Text(localizations.no_devices.capitalizeFirst!),
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
                                          ? AnimalItemSelectable(
                                              deviceImei: _animals[index].animal.animalName.value,
                                              deviceBattery: _animals[index].data.isNotEmpty
                                                  ? _animals[index].data.first.battery.value
                                                  : null,
                                              isSelected: _selectedAnimals
                                                  .where((element) =>
                                                      element.animal.idAnimal ==
                                                      _animals[index].animal.idAnimal)
                                                  .isNotEmpty,
                                              onSelected: () {
                                                int i = _selectedAnimals.indexWhere((element) =>
                                                    element.animal.idAnimal ==
                                                    _animals[index].animal.idAnimal);

                                                if (mounted) {
                                                  setState(() {
                                                    if (i >= 0) {
                                                      _selectedAnimals.removeAt(i);
                                                    } else {
                                                      _selectedAnimals.add(_animals[index]);
                                                    }
                                                  });
                                                }
                                              },
                                            )
                                          : AnimalItem(
                                              animal: _animals[index],
                                              deviceStatus: _animals[index].deviceStatus!,
                                              onBackFromDeviceScreen: () {
                                                _filterAnimals();
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
