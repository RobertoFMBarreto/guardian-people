import 'package:flutter/material.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class AdminDeviceManagementPage extends StatelessWidget {
  const AdminDeviceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
