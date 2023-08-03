import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/models/custom_floating_btn_options.dart';
import 'package:guardian/models/models/device.dart';
import 'package:guardian/models/models/devices.dart';
import 'package:guardian/models/models/focus_manager.dart';
import 'package:guardian/widgets/device_item.dart';
import 'package:guardian/widgets/floating_action_button.dart';
import 'package:guardian/widgets/inputs/range_input.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';
import 'package:guardian/widgets/pages/admin/producer_page/add_device_bottom_sheet.dart';
import 'package:guardian/widgets/pages/admin/producer_page/producer_page_drawer.dart';

import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class ProducerPage extends StatefulWidget {
  const ProducerPage({super.key});

  @override
  State<ProducerPage> createState() => _ProducerPageState();
}

class _ProducerPageState extends State<ProducerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchString = '';
  RangeValues _batteryRangeValues = const RangeValues(0, 100);
  RangeValues _dtUsageRangeValues = const RangeValues(0, 10);
  RangeValues _elevationRangeValues =
      const RangeValues(0, 1500); //!TODO: Get maior/menor altura de todos os devices
  RangeValues _tmpRangeValues =
      const RangeValues(0, 35); //!TODO: Get maior/menor tmp de todos os devices

  bool isRemoveMode = false;

  List<Device> devices = const [
    Device(
        imei: 999999999999999, dataUsage: 10, battery: 80, elevation: 417.42828, temperature: 24),
    Device(imei: 999999999999998, dataUsage: 9, battery: 50, elevation: 1013.5688, temperature: 24),
    Device(imei: 999999999999997, dataUsage: 8, battery: 75, elevation: 894.76483, temperature: 24),
    Device(imei: 999999999999996, dataUsage: 7, battery: 60, elevation: 134.28778, temperature: 24),
    Device(imei: 999999999999995, dataUsage: 6, battery: 90, elevation: 1500, temperature: 24),
    Device(imei: 999999999999994, dataUsage: 5, battery: 5, elevation: 1500, temperature: 24),
    Device(imei: 999999999999993, dataUsage: 4, battery: 15, elevation: 1500, temperature: 24),
    Device(imei: 999999999999992, dataUsage: 3, battery: 26, elevation: 1500, temperature: 24),
    Device(imei: 999999999999991, dataUsage: 2, battery: 40, elevation: 1500, temperature: 24),
    Device(imei: 999999999999990, dataUsage: 1, battery: 61, elevation: 1500, temperature: 24),
  ];

  List<Device> backupDevices = [];

  @override
  void initState() {
    // backup all devices
    backupDevices.addAll(devices);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    print('rebuild: $isRemoveMode');
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
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
        floatingActionButton: CustomFloatingActionButton(
          options: [
            CustomFloatingActionButtonOption(
              title: 'Adicionar Dispositivo',
              icon: Icons.add,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddDeviceBottomSheet(
                    onAddDevice: () {
                      //!TODO: Add device code
                    },
                  ),
                );
              },
            ),
            CustomFloatingActionButtonOption(
              title: isRemoveMode ? 'Cancelar' : 'Remover Dispositivo',
              icon: isRemoveMode ? Icons.cancel : Icons.remove,
              onTap: () {
                setState(() {
                  isRemoveMode = !isRemoveMode;
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                key: ValueKey('$isRemoveMode'),
                pinned: true,
                delegate: SliverMainAppBar(
                  imageUrl: '',
                  name: 'Nome Produtor',
                  title: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dispositivos',
                          style: theme.textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        isRemoveMode
                            ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    isRemoveMode = false;
                                  });
                                },
                                child: Text(
                                  'Cancelar',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: gdCancelTextColor,
                                  ),
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
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
                  tailWidget: IconButton(
                    icon: Icon(
                      Icons.delete_forever,
                      color: theme.colorScheme.onSecondary,
                      size: 30,
                    ),
                    onPressed: () {
                      //!TODO: Code for deleting the producer
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 12,
                        child: SearchFieldInput(
                          label: 'Pesquisar',
                          onChanged: (value) {
                            setState(() {
                              searchString = value;
                              devices = Devices.searchDevice(value, backupDevices);
                            });
                          },
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: IconButton(
                            icon: const Icon(Icons.filter_alt_outlined),
                            onPressed: () {
                              _scaffoldKey.currentState!.openEndDrawer();
                            },
                            iconSize: 30,
                          )),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) => DeviceItem(
                  deviceImei: devices[index].imei,
                  deviceData: devices[index].dataUsage,
                  deviceBattery: devices[index].battery,
                  isRemoveMode: isRemoveMode,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: deviceHeight * 0.1),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}