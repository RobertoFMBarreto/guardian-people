import 'package:flutter/material.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/devices.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';

import '../../widgets/device_item.dart';
import '../../widgets/pages/admin/producer_page/producer_page_drawer.dart';

class ProducerDevicesPage extends StatefulWidget {
  const ProducerDevicesPage({super.key});

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
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Dispositivos',
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
                      child: DeviceItem(
                        deviceImei: devices[index].imei,
                        deviceData: devices[index].data.first.dataUsage,
                        deviceBattery: devices[index].data.first.battery,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
