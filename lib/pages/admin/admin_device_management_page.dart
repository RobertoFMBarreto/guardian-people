import 'package:flutter/material.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/operations/device_operations.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';

import 'package:guardian/widgets/ui/device/device_item.dart';
import 'package:guardian/widgets/ui/device/option_button.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/sliver_device_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminDeviceManagementPage extends StatefulWidget {
  final Device device;
  final String producerId;

  const AdminDeviceManagementPage({
    super.key,
    required this.device,
    required this.producerId,
  });

  @override
  State<AdminDeviceManagementPage> createState() => _AdminDeviceManagementPageState();
}

class _AdminDeviceManagementPageState extends State<AdminDeviceManagementPage> {
  late Device _device;
  late Future _future;

  List<Device> _devices = [];

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    _device = widget.device;
    await _loadDevices();
  }

  Future<void> _loadDevices() async {
    // TODO : create operation for this
    await getUserDevices(uid: widget.producerId).then((allDevices) {
      if (mounted) {
        setState(() {
          _devices.addAll(allDevices.where((element) => element.deviceId != _device.deviceId));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(147, 215, 166, 1),
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomCircularProgressIndicator();
            } else {
              return CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverDeviceAppBar(
                      isWhiteBody: true,
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
                      device: _device,
                    ),
                  ),
                  if (hasConnection)
                    OptionButton(
                      key: Key(_device.isActive.toString()),
                      device: _device,
                      onRemove: () {
                        //TODO: Remove device
                        deleteDevice(_device.deviceId).then((_) {
                          Navigator.of(context).pop();
                        });
                      },
                      onBlock: () {
                        //TODO: block device

                        final newDevice = _device.copy(isActive: !_device.isActive);
                        updateDevice(newDevice).then((_) {
                          setState(
                            () {
                              _device = newDevice;
                            },
                          );
                        });
                      },
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      child: Text(
                        '${localizations.other_producer_devices.capitalize()}:',
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: DeviceItem(
                          device: _devices[index],
                          isPopPush: true,
                          producerId: widget.producerId,
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
