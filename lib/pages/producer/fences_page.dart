import 'package:flutter/material.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/devices.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/fence_item.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/pages/admin/producer_page/producer_page_drawer.dart';

class FencesPage extends StatefulWidget {
  const FencesPage({super.key});

  @override
  State<FencesPage> createState() => _FencesPageState();
}

class _FencesPageState extends State<FencesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchString = '';
  RangeValues _batteryRangeValues = const RangeValues(0, 100);
  RangeValues _dtUsageRangeValues = const RangeValues(0, 10);
  RangeValues _elevationRangeValues =
      const RangeValues(0, 1500); //TODO: Get maior/menor altura de todos os devices
  RangeValues _tmpRangeValues =
      const RangeValues(0, 35); //TODO: Get maior/menor tmp de todos os devices

  bool isRemoveMode = false;

  List<Device> backupDevices = [];
  List<Device> devices = [];
  List<Fence> fences = [];
  bool isLoading = true;
  @override
  void initState() {
    // backup all devices
    backupDevices.addAll(devices);
    _loadFences().then((value) => setState(() => isLoading = false));
    super.initState();
  }

  Future<void> _loadFences() async {
    loadUserFences(1).then((allFences) => setState(() => fences.addAll(allFences)));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Cercas',
            style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
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
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: fences.length,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed('/producer/fence/manage', arguments: fences[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: FenceItem(
                              name: fences[index].name,
                              color: HexColor(fences[index].fillColor),
                              onRemove: () {
                                //!TODO remove item from list
                              },
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
