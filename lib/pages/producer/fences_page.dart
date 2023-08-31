import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian/db/fence_operations.dart';
import 'package:guardian/models/custom_alert_dialogs.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/widgets/fence_item.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/selectable_fence_item.dart';

class FencesPage extends StatefulWidget {
  final bool isSelect;
  const FencesPage({super.key, this.isSelect = false});

  @override
  State<FencesPage> createState() => _FencesPageState();
}

class _FencesPageState extends State<FencesPage> {
  String searchString = '';
  List<Fence> fences = [];
  Fence? selectedFence;
  bool isLoading = true;

  late String uid;

  late StreamSubscription subscription;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    subscription = wifiConnectionChecker(
      context: context,
      onHasConnection: () async {
        print("Has Connection");
        await setShownNoWifiDialog(false);
      },
      onNotHasConnection: () async {
        print("No Connection");
        await hasShownNoWifiDialog().then((hasShown) async {
          if (!hasShown) {
            showNoWifiDialog(context);
            await setShownNoWifiDialog(true);
          }
        });
      },
    );
    _loadFences().then((_) {
      setState(() => isLoading = false);
    });
    super.initState();
  }

  Future<void> _loadFences() async {
    getUid(context).then(
      (userId) {
        if (userId != null) {
          uid = userId;
          _searchFences();
        }
      },
    );
  }

  void _searchFences() {
    searchFences(searchString).then(
      (allFences) => setState(() {
        fences = [];
        fences.addAll(allFences);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
        floatingActionButton: widget.isSelect && selectedFence != null
            ? FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                backgroundColor: theme.colorScheme.secondary,
                onPressed: () {
                  Navigator.of(context).pop(selectedFence);
                },
                label: Text(
                  localizations.confirm.capitalize(),
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: Icon(
                  Icons.done,
                  color: theme.colorScheme.onSecondary,
                ),
              )
            : widget.isSelect
                ? null
                : FloatingActionButton(
                    shape: const CircleBorder(),
                    backgroundColor: theme.colorScheme.secondary,
                    onPressed: () {
                      //!TODO:code to add a new fence
                      Navigator.of(context).pushNamed('/producer/geofencing').then(
                            (_) => _loadFences(),
                          );
                    },
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
        appBar: AppBar(
          title: Text(
            localizations.fences.capitalize(),
            style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SearchFieldInput(
                        label: localizations.search.capitalize(),
                        onChanged: (value) {
                          searchString = value;
                          _searchFences();
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: fences.length,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed('/producer/fence/manage', arguments: fences[index])
                                .then(
                                  (_) => _loadFences(),
                                );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: widget.isSelect
                                ? SelectableFenceItem(
                                    name: fences[index].name,
                                    color: HexColor(fences[index].color),
                                    isSelected: fences[index] == selectedFence,
                                    onSelected: () {
                                      //!TODO: select code
                                      if (selectedFence == fences[index]) {
                                        setState(() {
                                          selectedFence = null;
                                        });
                                      } else {
                                        setState(() {
                                          selectedFence = fences[index];
                                        });
                                      }
                                    })
                                : FenceItem(
                                    name: fences[index].name,
                                    color: HexColor(fences[index].color),
                                    onRemove: () {
                                      //!TODO remove item from list
                                      removeFence(fences[index]).then((_) => _loadFences());
                                    },
                                  ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
