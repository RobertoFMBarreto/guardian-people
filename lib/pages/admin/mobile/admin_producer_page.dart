import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/helpers/custom_floating_btn_option.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/admin/admin_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/admin/admin_users_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/settings/settings.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/animal/animal_item.dart';
import 'package:guardian/widgets/ui/animal/animal_item_removable.dart';
import 'package:guardian/widgets/ui/interactables/floating_action_button.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/ui/bottom_sheets/add_device_bottom_sheet.dart';
import 'package:guardian/widgets/ui/drawers/producer_page_drawer.dart';

import 'package:guardian/widgets/ui/topbars/main_topbar/sliver_main_app_bar.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminProducerPage extends StatefulWidget {
  final String producerId;

  const AdminProducerPage({
    super.key,
    required this.producerId,
  });

  @override
  State<AdminProducerPage> createState() => _AdminProducerPageState();
}

class _AdminProducerPageState extends State<AdminProducerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late double _maxElevation;
  late double _maxTemperature;
  late UserData _producer;
  late Future _future;

  String _searchString = '';
  late RangeValues _batteryRangeValues;
  late RangeValues _dtUsageRangeValues;
  late RangeValues _elevationRangeValues;
  late RangeValues _tmpRangeValues;
  bool _isRemoveMode = false;
  List<Animal> _devices = [];
  bool isLoading = true;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    await _setupFilterRanges();
    await _filterDevices().then((filteredDevices) async {
      setState(() {
        _devices = [];
        _devices.addAll(filteredDevices);
      });
      await getProducer(widget.producerId).then((user) {
        if (mounted) {
          setState(() {
            _producer = user;
          });
        }
      });
    });
  }

  Future<List<Animal>> _filterDevices() async {
    return await getProducerAnimalsFiltered(
      batteryRangeValues: _batteryRangeValues,
      elevationRangeValues: _elevationRangeValues,
      dtUsageRangeValues: _dtUsageRangeValues,
      searchString: _searchString,
      tmpRangeValues: _tmpRangeValues,
      idUser: widget.producerId,
    );
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
        _elevationRangeValues = const RangeValues(0, 1500);
        _tmpRangeValues = const RangeValues(0, 35);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    _isRemoveMode = _isRemoveMode && hasConnection == false;
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? gdGradientEnd
                : gdDarkGradientEnd,
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
          ),
          key: _scaffoldKey,
          endDrawer: _devices.isNotEmpty
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
                      _filterDevices().then(
                        (filteredDevices) => setState(() {
                          _devices = [];
                          _devices.addAll(filteredDevices);
                        }),
                      );

                      _scaffoldKey.currentState!.closeEndDrawer();
                    },
                    onResetFilters: () {
                      _resetFilters();
                      _filterDevices().then(
                        (filteredDevices) => setState(() {
                          _devices = [];
                          _devices.addAll(filteredDevices);
                        }),
                      );
                    },
                  ),
                )
              : null,
          floatingActionButton: hasConnection
              ? CustomFloatingActionButton(
                  options: [
                    CustomFloatingActionButtonOption(
                      title:
                          '${localizations.add.capitalizeFirst!} ${localizations.device.capitalizeFirst!}',
                      icon: Icons.add,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => AddDeviceBottomSheet(
                            onAddDevice: (imei, name) {
                              //TODO: Add device code
                              // createAnimal(AnimalCompanion(
                              //   idDevice: drift.Value(BigInt.from(Random().nextInt(90000))),
                              //   isActive: const drift.Value(true),
                              //   deviceName: drift.Value(name),
                              // )).then((newDevice) {
                              //   Navigator.of(context).pop();
                              //   _filterDevices().then((newDevices) {
                              //     setState(() {
                              //       _devices = [];
                              //       _devices.addAll(newDevices);
                              //     });
                              //   });
                              // });
                            },
                          ),
                        );
                      },
                    ),
                    CustomFloatingActionButtonOption(
                      title: _isRemoveMode
                          ? localizations.cancel.capitalizeFirst!
                          : '${localizations.remove.capitalizeFirst!} ${localizations.device.capitalizeFirst!}',
                      icon: _isRemoveMode ? Icons.cancel : Icons.remove,
                      onTap: () {
                        setState(() {
                          _isRemoveMode = !_isRemoveMode;
                        });
                      },
                    ),
                  ],
                )
              : null,
          body: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomCircularProgressIndicator();
                } else {
                  return SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        SliverPersistentHeader(
                          key: ValueKey('$_isRemoveMode'),
                          pinned: true,
                          delegate: SliverMainAppBar(
                            maxHeight: MediaQuery.of(context).size.height * gdTopBarHeightRatio,
                            imageUrl: '',
                            name: _producer.name,
                            title: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    localizations.devices.capitalizeFirst!,
                                    style: theme.textTheme.headlineSmall!.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  _isRemoveMode
                                      ? TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isRemoveMode = false;
                                            });
                                          },
                                          child: Text(
                                            localizations.confirm.capitalizeFirst!,
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
                            tailWidget: hasConnection
                                ? IconButton(
                                    icon: Icon(
                                      Icons.delete_forever,
                                      color: theme.colorScheme.onSecondary,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      //TODO: Code for deleting the producer
                                      Navigator.of(context).pop();
                                    },
                                  )
                                : null,
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
                                  _searchString = value;
                                  _filterDevices().then(
                                    (filteredDevices) => setState(() {
                                      _devices = [];
                                      _devices.addAll(filteredDevices);
                                    }),
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                        if (_devices.isEmpty)
                          SliverFillRemaining(
                            child: Center(child: Text(localizations.no_devices.capitalizeFirst!)),
                          ),
                        if (_devices.isNotEmpty)
                          SliverList.builder(
                            itemCount: _devices.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: _isRemoveMode
                                  ? AnimalItemRemovable(
                                      animal: _devices[index],
                                      onRemoveDevice: () {
                                        // TODO: On remove device code
                                        deleteAnimal(_devices[index].animal.idAnimal.value)
                                            .then((_) {
                                          setState(() {
                                            _devices.removeAt(index);
                                          });
                                        });
                                      },
                                    )
                                  : AnimalItem(
                                      animal: _devices[index],
                                      deviceStatus: _devices[index].deviceStatus!,
                                      producerId: widget.producerId,
                                    ),
                            ),
                          ),
                        if (_devices.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: deviceHeight * 0.1),
                            ),
                          )
                      ],
                    ),
                  );
                }
              })),
    );
  }
}
