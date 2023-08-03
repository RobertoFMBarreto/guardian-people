import 'package:guardian/widgets/pages/admin/admin_home/add_producer_bottom_sheet.dart';
import 'package:guardian/widgets/pages/admin/admin_home/highlights.dart';
import 'package:guardian/widgets/pages/admin/admin_home/producers.dart';
import 'package:flutter/material.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: SliverMainAppBar(
                imageUrl: '',
                name: 'Admin',
                isHomeShape: true,
                title: Text(
                  'Destaques',
                  style: theme.textTheme.headlineMedium!.copyWith(fontSize: 22),
                ),
                tailWidget: IconButton(
                  icon: Icon(
                    Icons.logout,
                    size: 30,
                    color: theme.colorScheme.onSecondary,
                  ),
                  onPressed: () {},
                ),
              ),
              pinned: true,
            ),
            const Highlights(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'Produtores',
                  style: theme.textTheme.headlineMedium!.copyWith(fontSize: 22),
                ),
              ),
            ),
            const Producers(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => AddProducerBottomSheet(
                    onAddProducer: () {
                      //!TODO: Add device code
                    },
                  ));
        },
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