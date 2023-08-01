import 'package:august_testing/widgets/pages/admin/admin_home/highlights.dart';
import 'package:august_testing/widgets/pages/admin/admin_home/producers.dart';
import 'package:august_testing/widgets/producer.dart';
import 'package:flutter/material.dart';

import '../../widgets/topbar/sliver_at_app_bar.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: SliverATAppBar(),
              pinned: true,
            ),
            const Highlights(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'Produtores',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),
            const Producers(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Adicionar Produtor',
        backgroundColor: theme.colorScheme.secondary,
        shape: const CircleBorder(),
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onSecondary,
          size: 40,
        ),
      ),
    );
  }
}
