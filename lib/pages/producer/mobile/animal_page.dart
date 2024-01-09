import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
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
  late Animal _animal;

  late StreamSubscription<BluetoothConnectionState> subscription;
  late BluetoothDevice device;

  bool _showedDataSent = false;
  bool _isInterval = false;
  int _reloadNum = 0;
  bool _firstRun = true;

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
    isSnackbarActive = false;
    _animal = widget.animal;
    connectToAnimal();
    super.initState();
  }

  Future<void> connectToAnimal() async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 60),
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
                String toSend = '';
                final characteristicSubscription = characteristic.onValueReceived.listen((payload) {
                  if (!_showedDataSent) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Sending Data...')));
                    _showedDataSent = false;
                  }
                  print("[BT][Payload] - ${payload}");
                  String data = String.fromCharCodes(payload
                      .toList()
                      .getRange(0, payload.length)
                      .join(',')
                      .split(',')
                      .map(int.parse));
                  if (data.contains('\$END')) {
                    toSend += data.replaceAll("STR\$", "").replaceAll("\$END", "");
                    _connectToSocket(toSend);
                    toSend = '';
                  } else {
                    toSend += data.replaceAll("STR\$", "").replaceAll("\$END", "");
                  }
                  print("[BT][DATA] - ${data.replaceAll("STR\$", "").replaceAll("\$END", "")}");
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

  void _connectToSocket(String toSend) {
    var addressesIListenFrom = InternetAddress.anyIPv4;
    int portIListenOn = 16123; //0 is random
    RawDatagramSocket.bind(addressesIListenFrom, portIListenOn).then((RawDatagramSocket udpSocket) {
      udpSocket.forEach((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = udpSocket.receive();
          if (dg != null) dg.data.forEach((x) => print(x));
        }
      });
      // final hexString = '0X${toSend.toRadixString(16)}';
      // print(hexString);
      udpSocket.send(utf8.encode(toSend), InternetAddress('77.54.1.149'), 47659);
      print('Did send data on the stream..');
    });
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
      onDataGotten: () {},
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
        isExtended: true,
        backgroundColor: theme.colorScheme.secondary,
        extendedPadding: const EdgeInsets.all(4),
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
                key: Key(
                    "${_animal.animal.animalName.value}${_animal.data}$hasConnection${theme.brightness}"),
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
                      onNewData: (AnimalLocationsCompanion newData) {
                        print(newData.temperature);
                        setState(() {
                          if (_isInterval) {
                            _animal.data.add(newData);
                          } else {
                            _animal.data.removeLast();
                            _animal.data.add(newData);
                          }
                        });
                      },
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
