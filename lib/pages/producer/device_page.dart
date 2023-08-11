import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/inputs/range_date_time_input.dart';
import 'package:guardian/widgets/maps/devices_locations_map.dart';
import 'package:guardian/widgets/maps/single_device_location_map.dart';
import 'package:guardian/widgets/pages/producer/device_page/device_time_widget.dart';
import 'package:guardian/widgets/topbars/device_topbar/sliver_device_app_bar.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DevicePage extends StatefulWidget {
  final Device device;
  const DevicePage({super.key, required this.device});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime startDateBackup = DateTime.now();
  DateTime endDateBackup = DateTime.now();
  bool isInterval = false;
  Position? _currentPosition;
  List<Fence> fences = [];

  @override
  void initState() {
    _loadFences().then((value) => _getCurrentPosition());
    super.initState();
  }

  Future<void> _loadFences() async {
    loadUserFences(1).then(
      (allFences) {
        setState(() {
          fences.addAll(allFences);
        });
      },
    );
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.reduced)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: _currentPosition == null
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverDeviceAppBar(
                      title: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Localização',
                              style: theme.textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ToggleSwitch(
                              initialLabelIndex: 0,
                              cornerRadius: 50,
                              radiusStyle: true,
                              activeBgColor: [theme.colorScheme.secondary],
                              activeFgColor: theme.colorScheme.onSecondary,
                              inactiveBgColor: gdToggleGreyArea,
                              inactiveFgColor: Colors.black,
                              customTextStyles: const [
                                TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                                TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                              ],
                              totalSwitches: 2,
                              labels: const [
                                'Atual',
                                'Intervalo',
                              ],
                              onToggle: (index) {
                                setState(() {
                                  isInterval = index == 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      device: widget.device,
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
                          Icons.settings_outlined,
                          color: theme.colorScheme.onSecondary,
                          size: 30,
                        ),
                        onPressed: () {
                          //TODO: Code for settings of device
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isInterval)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: DeviceTimeWidget(
                                startDate: startDate,
                                endDate: endDate,
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RangeDateTimeInput(
                                              startDate: startDate,
                                              endDate: endDate,
                                              onConfirm: (newStartDate, newEndDate) {
                                                setState(() {
                                                  startDate = newStartDate;
                                                  endDate = newEndDate;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        );
                                      });
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                              height: deviceHeight * 0.3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: SingleDeviceLocationMap(
                                  currentPosition: _currentPosition!,
                                  device: widget.device,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
