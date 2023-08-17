import 'package:flutter/material.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/device/device_item.dart';
import 'package:guardian/widgets/pages/admin/admin_device_management_page/option_button.dart';
import 'package:guardian/widgets/topbars/device_topbar/sliver_device_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminDeviceManagementPage extends StatefulWidget {
  final Device device;
  const AdminDeviceManagementPage({super.key, required this.device});

  @override
  State<AdminDeviceManagementPage> createState() => _AdminDeviceManagementPageState();
}

class _AdminDeviceManagementPageState extends State<AdminDeviceManagementPage> {
  List<Device> devices = [];
  bool isLoading = true;
  @override
  void initState() {
    _loadDevices();
    super.initState();
  }

  Future<void> _loadDevices() async {
    loadUserDevices(1).then((allDevices) {
      setState(() {
        devices.addAll(allDevices);
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
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
                      device: devices.first,
                    ),
                  ),
                  const OptionButton(),
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
                      itemBuilder: (context, index) => DeviceItem(
                        device: devices[index],
                        isPopPush: true,
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
