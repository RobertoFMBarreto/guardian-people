import 'package:flutter/foundation.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/data_models/user.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/operations/admin/admin_users_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/ui/dropdown/home_dropdown.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';
import 'package:guardian/widgets/ui/bottom_sheets/add_producer_bottom_sheet.dart';
import 'package:guardian/widgets/ui/user/producers.dart';
import 'package:flutter/material.dart';
import 'package:guardian/widgets/ui/topbars/main_topbar/sliver_main_app_bar.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({
    super.key,
  });

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late Future _future;

  List<User> _users = [];
  String _searchString = '';

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    await getProducersWithSearchAndDevicesAmount(_searchString).then(
      (usersData) {
        // TODO: get users and update db
        if (mounted) {
          setState(() {
            _users = [];
            _users.addAll(usersData);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light ? gdGradientEnd : gdDarkGradientEnd,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomCircularProgressIndicator();
            } else {
              return CustomScrollView(
                slivers: [
                  if (!kIsWeb)
                    SliverPersistentHeader(
                      delegate: SliverMainAppBar(
                        imageUrl: '',
                        name: 'Admin',
                        isHomeShape: true,
                        title: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: SearchFieldInput(
                            label: localizations.search.capitalize(),
                            onChanged: (value) {
                              _searchString = value;
                              _loadUsers();
                            },
                          ),
                        ),
                        tailWidget: const HomeDropDown(),
                      ),
                      pinned: true,
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 8.0),
                      child: Text(
                        localizations.producers.capitalize(),
                        style: theme.textTheme.headlineMedium!.copyWith(fontSize: kIsWeb ? 42 : 22),
                      ),
                    ),
                  ),
                  Producers(
                    producers: _users,
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: hasConnection
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => AddProducerBottomSheet(
                          onAddProducer: () {
                            // TODO: Add producer code
                          },
                        ));
              },
              tooltip: '${localizations.add.capitalize()} ${localizations.producer}',
              backgroundColor: theme.colorScheme.secondary,
              shape: const CircleBorder(),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onSecondary,
                size: 40,
              ),
            )
          : null,
    );
  }
}
