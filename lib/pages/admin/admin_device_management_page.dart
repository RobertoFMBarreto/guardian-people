import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian/db/device_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/device/device_item.dart';
import 'package:guardian/widgets/pages/admin/admin_device_management_page/option_button.dart';
import 'package:guardian/widgets/topbars/device_topbar/sliver_device_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminDeviceManagementPage extends StatefulWidget {
  final Device device;
  final String producerId;
  const AdminDeviceManagementPage({super.key, required this.device, required this.producerId});

  @override
  State<AdminDeviceManagementPage> createState() => _AdminDeviceManagementPageState();
}

class _AdminDeviceManagementPageState extends State<AdminDeviceManagementPage> {
  List<Device> devices = [];
  late Device device;
  bool isLoading = true;

  @override
  void initState() {
    _loadDevices();
    super.initState();
  }

  Future<void> _loadDevices() async {
    device = widget.device;
    getUserDevices(uid: widget.producerId).then((allDevices) {
      setState(() {
        devices.addAll(allDevices.where((element) => element.deviceId != device.deviceId));
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(147, 215, 166, 1),
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : CustomScrollView(
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
                      device: device,
                    ),
                  ),
                  OptionButton(
                    key: Key(device.isActive.toString()),
                    device: device,
                    onRemove: () {
                      //TODO: Remove device
                      deleteDevice(device.deviceId).then((_) {
                        Navigator.of(context).pop();
                      });
                    },
                    onBlock: () {
                      //TODO: block device

                      final newDevice = device.copy(isActive: !device.isActive);
                      updateDevice(newDevice).then((_) {
                        setState(
                          () {
                            device = newDevice;
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
                      itemCount: devices.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: DeviceItem(
                          device: devices[index],
                          isPopPush: true,
                          producerId: widget.producerId,
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
