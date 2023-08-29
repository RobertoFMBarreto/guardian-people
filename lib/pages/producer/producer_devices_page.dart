import 'package:flutter/material.dart';
import 'package:guardian/db/device_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/device/device_item_selectable.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';

import '../../widgets/device/device_item.dart';
import '../../widgets/pages/admin/producer_page/producer_page_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProducerDevicesPage extends StatefulWidget {
  final bool isSelect;
  final String? fenceId;
  final String? alertId;
  final List<String>? notToShowDevices;
  const ProducerDevicesPage({
    super.key,
    this.isSelect = false,
    this.fenceId,
    this.alertId,
    this.notToShowDevices,
  });

  @override
  State<ProducerDevicesPage> createState() => _ProducerDevicesPageState();
}

class _ProducerDevicesPageState extends State<ProducerDevicesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchString = '';
  RangeValues _batteryRangeValues = const RangeValues(0, 100);
  RangeValues _dtUsageRangeValues = const RangeValues(0, 10);
  RangeValues _elevationRangeValues =
      const RangeValues(0, 1500); //TODO: Get maior/menor altura de todos os devices
  RangeValues _tmpRangeValues =
      const RangeValues(0, 35); //TODO: Get maior/menor tmp de todos os devices

  bool isRemoveMode = false;

  List<Device> selectedDevices = [];
  List<Device> devices = [];

  late String uid;

  @override
  void initState() {
    getUid(context).then((userId) {
      if (userId != null) {
        uid = userId;
        _filterDevices();
      }
    });

    super.initState();
  }

  Future<void> _filterDevices() async {
    if (widget.isSelect && widget.fenceId != null) {
      await getUserFenceUnselectedDevicesFiltered(
        batteryRangeValues: _batteryRangeValues,
        elevationRangeValues: _elevationRangeValues,
        dtUsageRangeValues: _dtUsageRangeValues,
        searchString: searchString,
        tmpRangeValues: _tmpRangeValues,
        uid: uid,
        fenceId: widget.fenceId!,
      ).then((searchDevices) {
        setState(() {
          devices = [];
          devices.addAll(searchDevices);
        });
      });
    } else {
      getUserDevicesFiltered(
        batteryRangeValues: _batteryRangeValues,
        elevationRangeValues: _elevationRangeValues,
        dtUsageRangeValues: _dtUsageRangeValues,
        searchString: searchString,
        tmpRangeValues: _tmpRangeValues,
        uid: uid,
      ).then(
        (filteredDevices) => setState(() {
          devices = [];
          if (widget.notToShowDevices != null) {
            devices.addAll(
              filteredDevices.where(
                (device) => !widget.notToShowDevices!.contains(device.deviceId),
              ),
            );
          } else {
            devices.addAll(filteredDevices);
          }
        }),
      );
    }
  }

  Future<void> _resetFilters() async {
    setState(() {
      _batteryRangeValues = const RangeValues(0, 100);
      _dtUsageRangeValues = const RangeValues(0, 10);
      _elevationRangeValues = const RangeValues(0, 1500);
      _tmpRangeValues = const RangeValues(0, 35);
    });
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
        endDrawer: SafeArea(
          child: ProducerPageDrawer(
            batteryRangeValues: _batteryRangeValues,
            dtUsageRangeValues: _dtUsageRangeValues,
            tmpRangeValues: _tmpRangeValues,
            elevationRangeValues: _elevationRangeValues,
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
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: SearchWithFilterInput(
                  onFilter: () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  onSearchChanged: (value) {
                    searchString = value;
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
                        if (selectedDevices.length == devices.length) {
                          setState(() {
                            selectedDevices = [];
                          });
                        } else {
                          setState(() {
                            selectedDevices = devices;
                          });
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            selectedDevices.length == devices.length ? Icons.remove : Icons.add,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  //!TODO: get devices from fence data
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      child: widget.isSelect
                          ? DeviceItemSelectable(
                              deviceImei: devices[index].name,
                              deviceData: devices[index].data!.first.dataUsage,
                              deviceBattery: devices[index].data!.first.battery,
                              isSelected: selectedDevices
                                  .where((element) => element.deviceId == devices[index].deviceId)
                                  .isNotEmpty,
                              onSelected: () {
                                int i = selectedDevices.indexWhere(
                                    (element) => element.deviceId == devices[index].deviceId);
                                setState(() {
                                  if (i >= 0) {
                                    selectedDevices.removeAt(i);
                                  } else {
                                    selectedDevices.add(devices[index]);
                                  }
                                });
                              },
                            )
                          : DeviceItem(
                              device: devices[index],
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
        ),
        floatingActionButton: widget.isSelect && selectedDevices.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).pop(selectedDevices);
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
      ),
    );
  }
}
