import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/inputs/range_date_time_input.dart';
import 'package:guardian/widgets/maps/single_device_location_map.dart';
import 'package:guardian/widgets/pages/producer/device_page/device_time_widget.dart';

class DeviceMapWidget extends StatefulWidget {
  final Device device;
  final bool isInterval;
  const DeviceMapWidget({super.key, required this.device, required this.isInterval});

  @override
  State<DeviceMapWidget> createState() => _DeviceMapWidgetState();
}

class _DeviceMapWidgetState extends State<DeviceMapWidget> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime startDateBackup = DateTime.now();
  DateTime endDateBackup = DateTime.now();
  bool showFence = true;
  Position? _currentPosition;
  List<Fence> fences = [];

  double currentZoom = 17;

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
    return _currentPosition == null
        ? Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.secondary,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.isInterval)
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
                padding: const EdgeInsets.only(right: 10.0, top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Mostrar cerca:",
                      style: theme.textTheme.bodyLarge,
                    ),
                    Switch(
                        activeTrackColor: theme.colorScheme.secondary,
                        value: showFence,
                        onChanged: (value) {
                          setState(() {
                            showFence = value;
                          });
                        }),
                  ],
                ),
              ),
              SizedBox(
                height: deviceHeight * 0.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SingleDeviceLocationMap(
                    key: Key('$showFence'),
                    currentPosition: _currentPosition!,
                    device: widget.device,
                    showFence: showFence,
                    isInterval: widget.isInterval,
                    endDate: endDate,
                    startDate: startDate,
                    onZoomChange: (newZoom) {
                      // No need to setstate because we dont need to update the screen
                      // just need to store the value in case the map restarts to keep zoom
                      currentZoom = newZoom;
                    },
                    startingZoom: currentZoom,
                  ),
                ),
              ),
            ],
          );
  }
}