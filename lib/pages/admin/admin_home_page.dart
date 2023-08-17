import 'package:flutter/foundation.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/widgets/pages/admin/admin_home/add_producer_bottom_sheet.dart';
import 'package:guardian/widgets/pages/admin/admin_home/highlights.dart';
import 'package:guardian/widgets/pages/admin/admin_home/producers.dart';
import 'package:flutter/material.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<User> users = [];
  bool isLoading = true;
  @override
  void initState() {
    _loadUser();
    super.initState();
  }

  Future<void> _loadUser() async {
    loadUsersRole(1).then((allUsers) {
      setState(() {
        users.addAll(allUsers);
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
            : Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (!kIsWeb)
                      SliverPersistentHeader(
                        delegate: SliverMainAppBar(
                          imageUrl: '',
                          name: 'Admin',
                          isHomeShape: true,
                          title: Text(
                            localizations.highlights.capitalize(),
                            style: theme.textTheme.headlineMedium!.copyWith(fontSize: 22),
                          ),
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
                              PopupMenuItem(
                                value: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(localizations.profile.capitalize()),
                                    const Icon(
                                      Icons.person,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(localizations.logout.capitalize()),
                                    const Icon(
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
                    Highlights(users: users.sublist(0, 2)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          localizations.producers.capitalize(),
                          style:
                              theme.textTheme.headlineMedium!.copyWith(fontSize: kIsWeb ? 42 : 22),
                        ),
                      ),
                    ),
                    Producers(
                      producers: users,
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => AddProducerBottomSheet(
                    onAddProducer: () {
                      //TODO: Add device code
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
