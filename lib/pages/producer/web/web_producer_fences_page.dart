import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/tmp/read_json.dart';
import 'package:guardian/pages/producer/web/widget/geofencing.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/fence/fence_item.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';

class WebProducerFencesPage extends StatefulWidget {
  const WebProducerFencesPage({super.key});

  @override
  State<WebProducerFencesPage> createState() => _WebProducerFencesPageState();
}

class _WebProducerFencesPageState extends State<WebProducerFencesPage> {
  final List<FenceData> _fences = [];
  final TextEditingController _nameController = TextEditingController();

  late Future _future;

  FenceData? _selectedFence = null;
  bool isInteractingFence = false;

  String _searchString = '';
  String _fenceName = '';

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  Future<void> _setup() async {
    await _loadFences();
  }

  Future<void> _loadFences() async {
    await getUserFences().then((allFences) => setState(() {
          _fences.addAll(allFences);
          print(_fences);
        }));
  }

  Future<void> _filterFences() async {}

  Future<void> _confirmGeofence() async {}

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomCircularProgressIndicator();
          } else {
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  localizations.fences.capitalize(),
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SearchWithFilterInput(
                                              onFilter: () {},
                                              onSearchChanged: (value) {
                                                _searchString = value;
                                                _filterFences();
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: _fences.length,
                                                itemBuilder: (context, index) {
                                                  return FenceItem(
                                                    name: _fences[index].name,
                                                    isSelected: _selectedFence != null &&
                                                        _selectedFence!.idFence ==
                                                            _fences[index].idFence,
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedFence = _fences[index];
                                                        isInteractingFence = true;
                                                      });
                                                    },
                                                    color: HexColor(_fences[index].color),
                                                    onRemove: () {
                                                      removeFence(_fences[index].idFence);
                                                      setState(() {
                                                        _fences.removeWhere(
                                                          (element) =>
                                                              element.idFence ==
                                                              _fences[index].idFence,
                                                        );
                                                      });
                                                      // TODO remove item service call
                                                    },
                                                  );
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        if (_selectedFence != null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: TextField(
                                        onChanged: (newValue) {
                                          _fenceName = newValue;
                                        },
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          label: Text(
                                            localizations.fence_name.capitalize(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(gdDarkCancelBtnColor),
                                          ),
                                          child: Text(
                                            localizations.cancel.capitalize(),
                                            style: theme.textTheme.bodyLarge!.copyWith(
                                              color: theme.colorScheme.onSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _confirmGeofence();
                                          },
                                          child: Text(
                                            localizations.confirm.capitalize(),
                                            style: theme.textTheme.bodyLarge!.copyWith(
                                              color: theme.colorScheme.onSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: isInteractingFence
                          ? Geofencing(
                              key: Key(_selectedFence!.idFence.toString()),
                              fence: _selectedFence,
                            )
                          : DevicesLocationsMap(
                              key: Key(_fences.toString()),
                              showCurrentPosition: true,
                              animals: [],
                              fences: _fences,
                              centerOnPoly: _fences.isNotEmpty,
                            ),
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }
}
