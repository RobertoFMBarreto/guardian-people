import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/device_operations.dart';
import 'package:guardian/models/custom_floating_btn_option.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/widgets/device/device_item.dart';
import 'package:guardian/widgets/device/device_item_removable.dart';
import 'package:guardian/widgets/floating_action_button.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/pages/admin/producer_page/add_device_bottom_sheet.dart';
import 'package:guardian/widgets/pages/admin/producer_page/producer_page_drawer.dart';

import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminProducerPage extends StatefulWidget {
  final String producerId;
  const AdminProducerPage({super.key, required this.producerId});

  @override
  State<AdminProducerPage> createState() => _AdminProducerPageState();
}

class _AdminProducerPageState extends State<AdminProducerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchString = '';
  RangeValues _batteryRangeValues = const RangeValues(0, 100);
  RangeValues _dtUsageRangeValues = const RangeValues(0, 10);
  RangeValues _elevationRangeValues =
      const RangeValues(0, 1500); //TODO: Get maior/menor altura de todos os devices
  RangeValues _tmpRangeValues =
      const RangeValues(0, 35); //TODO: Get maior/menor tmp de todos os devices

  bool isRemoveMode = false;

  List<Device> devices = [];

  @override
  void initState() {
    _filterDevices().then(
      (filteredDevices) => setState(() {
        devices = [];
        devices.addAll(filteredDevices);
      }),
    );
    super.initState();
  }

  Future<List<Device>> _filterDevices() async {
    return await getUserDevicesFiltered(
      batteryRangeValues: _batteryRangeValues,
      elevationRangeValues: _elevationRangeValues,
      dtUsageRangeValues: _dtUsageRangeValues,
      searchString: searchString,
      tmpRangeValues: _tmpRangeValues,
      uid: widget.producerId,
    );
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
    double deviceHeight = MediaQuery.of(context).size.height;

    AppLocalizations localizations = AppLocalizations.of(context)!;
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
              _filterDevices().then(
                (filteredDevices) => setState(() {
                  devices = [];
                  devices.addAll(filteredDevices);
                }),
              );

              _scaffoldKey.currentState!.closeEndDrawer();
            },
            onResetFilters: () {
              _resetFilters();
              _filterDevices().then(
                (filteredDevices) => setState(() {
                  devices = [];
                  devices.addAll(filteredDevices);
                }),
              );
            },
          ),
        ),
        floatingActionButton: CustomFloatingActionButton(
          options: [
            CustomFloatingActionButtonOption(
              title: '${localizations.add.capitalize()} ${localizations.device.capitalize()}',
              icon: Icons.add,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddDeviceBottomSheet(
                    onAddDevice: () {
                      //TODO: Add device code
                    },
                  ),
                );
              },
            ),
            CustomFloatingActionButtonOption(
              title: isRemoveMode
                  ? localizations.cancel.capitalize()
                  : '${localizations.remove.capitalize()} ${localizations.device.capitalize()}',
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
                          localizations.devices.capitalize(),
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
                                  localizations.cancel.capitalize(),
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
                      //TODO: Code for deleting the producer
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: SearchWithFilterInput(
                    onFilter: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                    onSearchChanged: (value) {
                      setState(() {
                        searchString = value;
                        _filterDevices().then(
                          (filteredDevices) => setState(() {
                            devices = [];
                            devices.addAll(filteredDevices);
                          }),
                        );
                      });
                    },
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: isRemoveMode
                      ? DeviceItemRemovable(
                          deviceTitle: devices[index].imei,
                          deviceData: devices[index].data!.first.dataUsage,
                          deviceBattery: devices[index].data!.first.battery,
                          onRemoveDevice: () {},
                        )
                      : DeviceItem(
                          device: devices[index],
                        ),
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
