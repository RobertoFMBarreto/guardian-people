import 'package:flutter/material.dart';

import '../../widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class ProducerPage extends StatelessWidget {
  const ProducerPage({super.key});

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
                leadingWidget: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSecondary,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
                tailWidget: IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: theme.colorScheme.onSecondary,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
