import 'package:flutter/material.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class ProducerHome extends StatelessWidget {
  const ProducerHome({super.key});

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
                name: 'João Gonçalves',
                isHomeShape: true,
                tailWidget: PopupMenuButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: theme.colorScheme.onSecondary,
                  icon: const Icon(Icons.menu),
                  onSelected: (item) {
                    switch (item) {
                      case 0:
                        Navigator.of(context).pushNamed('/profile');
                        break;
                      case 1:
                        //! Logout code
                        clearUserSession().then(
                          (value) => Navigator.of(context).popAndPushNamed('/login'),
                        );

                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Perfil'),
                          Icon(
                            Icons.person,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Sair'),
                          Icon(
                            Icons.logout,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pinned: true,
            ),
          ],
        ),
      ),
    );
  }
}
