import 'package:flutter/material.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/fences.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/fence_item.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FencesPage extends StatefulWidget {
  const FencesPage({super.key});

  @override
  State<FencesPage> createState() => _FencesPageState();
}

class _FencesPageState extends State<FencesPage> {
  String searchString = '';
  List<Fence> backupFences = [];
  List<Fence> fences = [];
  bool isLoading = true;
  @override
  void initState() {
    _loadFences().then((value) => setState(() => isLoading = false));
    super.initState();
  }

  Future<void> _loadFences() async {
    loadUserFences(1).then((allFences) {
      setState(() => fences.addAll(allFences));
      // backup all fences
      backupFences.addAll(fences);
    });
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
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: theme.colorScheme.secondary,
          onPressed: () {
            //!TODO:code to add a new fence
            Navigator.of(context).pushNamed('/producer/geofencing');
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
                          setState(() {
                            searchString = value;
                            fences = Fences.searchFences(value, backupFences);
                          });
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
                                .pushNamed('/producer/fence/manage', arguments: fences[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: FenceItem(
                              name: fences[index].name,
                              color: HexColor(fences[index].color),
                              onRemove: () {
                                //!TODO remove item from list
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
