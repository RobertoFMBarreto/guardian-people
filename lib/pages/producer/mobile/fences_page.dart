import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/fence/fence_item.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/fence/selectable_fence_item.dart';

class FencesPage extends StatefulWidget {
  final bool isSelect;

  const FencesPage({
    super.key,
    this.isSelect = false,
  });

  @override
  State<FencesPage> createState() => _FencesPageState();
}

class _FencesPageState extends State<FencesPage> {
  late String uid;
  late Future _future;

  String _searchString = '';
  List<FenceData> _fences = [];
  FenceData? _selectedFence;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    await _searchFences();
  }

  Future<void> _searchFences() async {
    await searchFences(_searchString).then((allFences) {
      if (mounted) {
        setState(() {
          _fences = [];
          _fences.addAll(allFences);
        });
      }
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
          floatingActionButton: widget.isSelect && _selectedFence != null
              ? FloatingActionButton.extended(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  backgroundColor: theme.colorScheme.secondary,
                  onPressed: () {
                    Navigator.of(context).pop(_selectedFence);
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
              : widget.isSelect || !hasConnection
                  ? null
                  : FloatingActionButton(
                      shape: const CircleBorder(),
                      backgroundColor: theme.colorScheme.secondary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          CustomPageRouter(
                            page: '/producer/geofencing',
                          ),
                        ).then(
                          (_) => _searchFences(),
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
          body: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomCircularProgressIndicator();
                } else {
                  return SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SearchFieldInput(
                            label: localizations.search.capitalize(),
                            onChanged: (value) {
                              _searchString = value;
                              _searchFences();
                            },
                          ),
                        ),
                        Expanded(
                          child: _fences.isEmpty
                              ? Center(
                                  child: Text(
                                    localizations.no_fences.capitalize(),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  itemCount: _fences.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: widget.isSelect
                                        ? SelectableFenceItem(
                                            name: _fences[index].name,
                                            color: HexColor(_fences[index].color),
                                            isSelected: _fences[index] == _selectedFence,
                                            onSelected: () {
                                              // TODO: select code
                                              if (_selectedFence == _fences[index]) {
                                                setState(() {
                                                  _selectedFence = null;
                                                });
                                              } else {
                                                setState(() {
                                                  _selectedFence = _fences[index];
                                                });
                                              }
                                            })
                                        : FenceItem(
                                            name: _fences[index].name,
                                            color: HexColor(_fences[index].color),
                                            onTap: () {
                                              Navigator.of(context)
                                                  .pushNamed('/producer/fence/manage',
                                                      arguments: _fences[index])
                                                  .then(
                                                    (_) => _searchFences(),
                                                  );
                                            },
                                            onRemove: () {
                                              // TODO remove item from list
                                              removeFence(_fences[index].toCompanion(true))
                                                  .then((_) => _searchFences());
                                            },
                                          ),
                                  ),
                                ),
                        )
                      ],
                    ),
                  );
                }
              })),
    );
  }
}