import 'package:flutter/material.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/devices.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/device/device_item_selectable.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';

import '../../widgets/device/device_item.dart';
import '../../widgets/pages/admin/producer_page/producer_page_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProducerDevicesPage extends StatefulWidget {
  final bool isSelect;
  const ProducerDevicesPage({super.key, this.isSelect = false});

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
  List<Device> backupDevices = [];
  List<Device> devices = [];
  @override
  void initState() {
    _loadDevices();
    super.initState();
  }

  Future<void> _loadDevices() async {
    loadUserDevices(1).then((allDevices) {
      setState(() => devices.addAll(allDevices));
      backupDevices.addAll(allDevices);
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
              setState(() {
                devices = Devices.filterByAll(
                  batteryRangeValues: _batteryRangeValues,
                  dtUsageRangeValues: _dtUsageRangeValues,
                  tmpRangeValues: _tmpRangeValues,
                  elevationRangeValues: _elevationRangeValues,
                  searchString: searchString,
                  devicesList: backupDevices,
                );
              });
              _scaffoldKey.currentState!.closeEndDrawer();
            },
            onResetFilters: () {
              setState(() {
                _batteryRangeValues = const RangeValues(0, 100);
                _dtUsageRangeValues = const RangeValues(0, 10);
                _elevationRangeValues = const RangeValues(0, 1500);
                _tmpRangeValues = const RangeValues(0, 35);
                devices = Devices.filterByAll(
                  batteryRangeValues: _batteryRangeValues,
                  dtUsageRangeValues: _dtUsageRangeValues,
                  tmpRangeValues: _tmpRangeValues,
                  elevationRangeValues: _elevationRangeValues,
                  searchString: searchString,
                  devicesList: backupDevices,
                );
              });
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
                    setState(() {
                      searchString = value;
                      devices = Devices.searchDevice(value, backupDevices);
                    });
                  },
                ),
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
                              deviceImei: devices[index].imei,
                              deviceData: devices[index].data.first.dataUsage,
                              deviceBattery: devices[index].data.first.battery,
                              isSelected: selectedDevices
                                  .where((element) => element.imei == devices[index].imei)
                                  .isNotEmpty,
                              onSelected: () {
                                int i = selectedDevices
                                    .indexWhere((element) => element.imei == devices[index].imei);
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
                  'Concluído',
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(Icons.add),
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              )
            : null,
      ),
    );
  }
}
