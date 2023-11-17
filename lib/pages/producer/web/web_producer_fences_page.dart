import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/widgets/ui/common/geofencing.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/fence/fence_item.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';
import 'package:drift/drift.dart' as drift;

/// Class that represents the web producer fences page
class WebProducerFencesPage extends StatefulWidget {
  const WebProducerFencesPage({super.key});

  @override
  State<WebProducerFencesPage> createState() => _WebProducerFencesPageState();
}

class _WebProducerFencesPageState extends State<WebProducerFencesPage> {
  final TextEditingController _nameController = TextEditingController();
  late Future _future;

  FenceData? _selectedFence;
  bool isInteractingFence = false;
  List<Animal> _animals = [];
  List<FenceData> _fences = [];

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  /// Method that does the initial setup of the page
  Future<void> _setup() async {
    await _loadFences();
    await _loadAnimals();
  }

  /// Method that loads the animals into the [_animals] list
  ///
  /// 1. load local animals
  /// 2. add to list
  /// 3. load api animals
  Future<void> _loadAnimals() async {
    await getUserAnimalsWithLastLocation().then((allAnimals) {
      _animals = [];
      setState(() {
        _animals.addAll(allAnimals);
      });
      AnimalRequests.getAnimalsFromApiWithLastLocation(
          context: context,
          onDataGotten: () {
            getUserAnimalsWithLastLocation().then((allDevices) {
              if (mounted) {
                setState(() {
                  _animals = [];
                  _animals.addAll(allDevices);
                });
              }
            });
          });
    });
  }

  /// Method that loads the fences into the [_fences] list
  Future<void> _loadFences() async {
    await _loadLocalFences().then(
      (_) => FencingRequests.getUserFences(
        context: context,
        onGottenData: (data) async {
          await _loadLocalFences();
        },
        onFailed: () {},
      ),
    );
  }

  /// Method that loads the fences into the [_fences] list
  Future<void> _loadLocalFences() async {
    await getUserFences().then((allFences) => setState(() {
          _fences = [];
          _fences.addAll(allFences);
        }));
  }

  Future<void> _filterFences() async {}

  /// Method that allows to delete a fence and update the fences list
  Future<void> _deleteFence(String idFence) async {
    final fence = _fences.firstWhere(
      (element) => element.idFence == idFence,
    );
    await getOriginalFencePoints(idFence).then((fencePoints) => getFenceAnimals(idFence).then(
          (fenceAnimals) => FencingRequests.removeFence(
            idFence: idFence,
            context: context,
            onGottenData: () async {
              await removeFence(idFence).then((_) async {
                await _loadLocalFences();
              });
            },
            onFailed: () async {
              // await createFence(FenceCompanion(
              //   color: drift.Value(fence.color),
              //   idFence: drift.Value(fence.idFence),
              //   idUser: drift.Value(fence.idUser),
              //   isStayInside: drift.Value(fence.isStayInside),
              //   name: drift.Value(fence.name),
              // ));
              // for (var point in fencePoints) {
              //   await createFencePoint(point.toCompanion(true));
              // }
              // for (var animal in fenceAnimals) {
              //   await createFenceAnimal(
              //     FenceAnimalsCompanion(
              //       idAnimal: animal.animal.idAnimal,
              //       idFence: drift.Value(idFence),
              //     ),
              //   );
              // }
              // await _loadFences();
            },
          ),
        ));
  }

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
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            localizations.fences.capitalizeFirst!,
                                            style: theme.textTheme.headlineMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              if (_selectedFence != null) {
                                                _selectedFence = null;
                                              }
                                              setState(() {
                                                isInteractingFence = !isInteractingFence;
                                              });
                                            },
                                            icon: Icon(
                                              _selectedFence == null && !isInteractingFence
                                                  ? Icons.add
                                                  : Icons.close,
                                            ),
                                            label: Text(
                                              _selectedFence == null && !isInteractingFence
                                                  ? '${localizations.add.capitalizeFirst!} ${localizations.fence.capitalizeFirst!}'
                                                  : localizations.cancel.capitalizeFirst!,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                                                      if (_selectedFence != null &&
                                                          _selectedFence!.idFence ==
                                                              _fences[index].idFence) {
                                                        setState(() {
                                                          _selectedFence = null;
                                                          isInteractingFence = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          _selectedFence = _fences[index];
                                                          isInteractingFence = true;
                                                        });
                                                      }
                                                    },
                                                    color: HexColor(_fences[index].color),
                                                    onRemove: () {
                                                      _deleteFence(_fences[index].idFence);
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
                              key: Key(
                                  '${_selectedFence != null ? _selectedFence!.idFence.toString() : _selectedFence}'),
                              fence: _selectedFence,
                              onFenceCreated: () async {
                                setState(() {
                                  isInteractingFence = false;
                                  _selectedFence = null;
                                });
                                await _loadFences();
                              },
                            )
                          : AnimalsLocationsMap(
                              key: Key(_fences.toString()),
                              showCurrentPosition: true,
                              animals: _animals,
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
