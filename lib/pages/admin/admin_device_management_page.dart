import 'package:flutter/material.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/widgets/device/device_item.dart';
import 'package:guardian/widgets/pages/admin/admin_device_management_page/option_button.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class AdminDeviceManagementPage extends StatelessWidget {
  const AdminDeviceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Device> devices = [];
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
