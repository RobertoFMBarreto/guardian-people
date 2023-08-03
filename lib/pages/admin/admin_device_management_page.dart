import 'package:flutter/material.dart';
import 'package:guardian/models/models/device.dart';
import 'package:guardian/widgets/device_item.dart';
import 'package:guardian/widgets/pages/admin/admin_device_management_page/option_button.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class AdminDeviceManagementPage extends StatelessWidget {
  const AdminDeviceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Device> devices = const [
      Device(
          imei: 999999999999999, dataUsage: 10, battery: 80, elevation: 417.42828, temperature: 24),
      Device(
          imei: 999999999999998, dataUsage: 9, battery: 50, elevation: 1013.5688, temperature: 24),
      Device(
          imei: 999999999999997, dataUsage: 8, battery: 75, elevation: 894.76483, temperature: 24),
      Device(
          imei: 999999999999996, dataUsage: 7, battery: 60, elevation: 134.28778, temperature: 24),
      Device(imei: 999999999999995, dataUsage: 6, battery: 90, elevation: 1500, temperature: 24),
      Device(imei: 999999999999994, dataUsage: 5, battery: 5, elevation: 1500, temperature: 24),
      Device(imei: 999999999999993, dataUsage: 4, battery: 15, elevation: 1500, temperature: 24),
      Device(imei: 999999999999992, dataUsage: 3, battery: 26, elevation: 1500, temperature: 24),
      Device(imei: 999999999999991, dataUsage: 2, battery: 40, elevation: 1500, temperature: 24),
      Device(imei: 999999999999990, dataUsage: 1, battery: 61, elevation: 1500, temperature: 24),
    ];

    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverMainAppBar(
                imageUrl: '',
                name: 'Nome Produtor',
                isDeviceShape: true,
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
              ),
            ),
            const OptionButton(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Text(
                  'Outros dispositivos do produtor',
                  style: theme.textTheme.headlineSmall!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SliverFillRemaining(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) => DeviceItem(
                  deviceImei: devices[index].imei,
                  deviceData: devices[index].dataUsage,
                  deviceBattery: devices[index].battery,
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
