import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/admin/admin_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/device_operations.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:drift/drift.dart' as drift;
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

  final List<Device> _devices = [];

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
    await getProducerDevices(widget.producerId).then((allDevices) {
      if (mounted) {
        setState(() {
          _devices.addAll(
              allDevices.where((element) => element.device.deviceId != _device.device.deviceId));
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
        backgroundColor:
            Theme.of(context).brightness == Brightness.light ? gdGradientEnd : gdDarkGradientEnd,
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
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
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
                      key: Key(_device.device.isActive.value.toString()),
                      device: _device,
                      onRemove: () {
                        //TODO: Remove device
                        deleteDevice(_device.device.deviceId.value).then((_) {
                          Navigator.of(context).pop();
                        });
                      },
                      onBlock: () {
                        //TODO: block device

                        final newDevice = _device.device
                            .copyWith(isActive: drift.Value(!_device.device.isActive.value));
                        updateDevice(newDevice).then((_) {
                          setState(
                            () {
                              _device = Device(device: newDevice, data: _device.data);
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
                  if (_devices.isEmpty)
                    SliverFillRemaining(
                      child: Center(child: Text(localizations.no_devices.capitalize())),
                    ),
                  if (_devices.isNotEmpty)
                    SliverFillRemaining(
                      child: ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: DeviceItem(
                            device: _devices[index],
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