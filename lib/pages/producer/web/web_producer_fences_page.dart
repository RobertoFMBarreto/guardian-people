import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/pages/producer/web/widget/select_device_dialogue.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/ui/animal/animal_item_removable.dart';
import 'package:guardian/widgets/ui/common/geofencing.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/fence/fence_item.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';

/// Class that represents the web producer fences page
class WebProducerFencesPage extends StatefulWidget {
  const WebProducerFencesPage({super.key});

  @override
  State<WebProducerFencesPage> createState() => _WebProducerFencesPageState();
}

class _WebProducerFencesPageState extends State<WebProducerFencesPage> {
  late Future _future;

  final GlobalKey _mapParentKey = GlobalKey();
  FenceData? _selectedFence;
  bool isInteractingFence = false;
  bool _firstRun = true;
  List<Animal> _animals = [];
  List<Animal> _fenceAnimals = [];
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
          onFailed: (statusCode) {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(localizations.server_error)));
          },
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
          await _loadLocalFences().then((value) => null);
        },
        onFailed: (statusCode) {
          AppLocalizations localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(localizations.server_error)));
        },
      ),
    );
  }

  Future<void> _loadFenceAnimals() async {
    await getFenceAnimals(_selectedFence!.idFence).then(
      (allDevices) => setState(() {
        _fenceAnimals = [];
        _fenceAnimals.addAll(allDevices);
      }),
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
            onFailed: (statusCode) async {
              if (kIsWeb) {
                AppLocalizations localizations = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(localizations.server_error)));
              } else {
                if (!hasConnection && !isSnackbarActive) {
                  showNoConnectionSnackBar();
                } else {
                  if (statusCode == 507 || statusCode == 404) {
                    if (_firstRun == true) {
                      showNoConnectionSnackBar();
                    }
                    _firstRun = false;
                  } else if (!isSnackbarActive) {
                    AppLocalizations localizations = AppLocalizations.of(context)!;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(localizations.server_error)));
                  }
                }
              }
              setState(() {
                _fences.add(fence);
              });
            },
          ),
        ));
  }

  Future<void> _onRemoveDevice(int index) async {
    //store the animal
    final animal = _fenceAnimals[index];
    final fence = _selectedFence;
    setState(() {
      _fenceAnimals.removeWhere(
        (element) => element.animal.idAnimal == _fenceAnimals[index].animal.idAnimal,
      );
    });
    await FencingRequests.removeAnimalFence(
      animalIds: [animal.animal.idAnimal.value],
      context: context,
      fenceId: fence!.idFence,
      onDataGotten: () async {
        await removeAnimalFence(fence.idFence, animal.animal.idAnimal.value);
      },
      onFailed: (statusCode) {
        if (kIsWeb) {
          AppLocalizations localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(localizations.server_error)));
        } else {
          if (!hasConnection && !isSnackbarActive) {
            showNoConnectionSnackBar();
          } else {
            if (statusCode == 507 || statusCode == 404) {
              if (_firstRun == true) {
                showNoConnectionSnackBar();
              }
              _firstRun = false;
            } else if (!isSnackbarActive) {
              AppLocalizations localizations = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(localizations.server_error)));
            }
          }
          setState(() {
            _fenceAnimals.add(animal);
          });
        }
      },
    );
  }

  /// Method that pushes to the devices pages and allows to select the devices for the alert
  ///
  /// When it gets back from the page it inserts all devices in the [_alertAnimals] list
  Future<void> _onAddAnimals() async {
    showDialog(
      context: context,
      builder: (context) {
        ThemeData theme = Theme.of(context);
        return Dialog(
          backgroundColor:
              theme.brightness == Brightness.light ? gdBackgroundColor : gdDarkBackgroundColor,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Scaffold(
                body: SelectDeviceDialogue(
                  idAlert: _selectedFence?.idFence,
                  notToShowAnimals: _fenceAnimals.map((e) => e.animal.idAnimal.value).toList(),
                ),
              ),
            ),
          ),
        );
      },
    ).then((selectedDevices) async {
      if (selectedDevices != null && selectedDevices.runtimeType == List<Animal>) {
        final selected = selectedDevices as List<Animal>;
        setState(() {
          _fenceAnimals.addAll(selected);
        });
        _createFenceAnimals(selected).then(
          (_) => FencingRequests.addAnimalFence(
            fenceId: _selectedFence!.idFence,
            animalIds: selected.map((e) => e.animal.idAnimal.value).toList(),
            context: context,
            onFailed: (statusCode) {
              if (!hasConnection && !isSnackbarActive) {
                showNoConnectionSnackBar();
              } else {
                if (statusCode == 507 || statusCode == 404) {
                  if (_firstRun == true) {
                    showNoConnectionSnackBar();
                  }
                  _firstRun = false;
                } else if (!isSnackbarActive) {
                  AppLocalizations localizations = AppLocalizations.of(context)!;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(localizations.server_error)));
                }
              }
            },
          ),
        );
      }
    });
  }

  Future<void> _createFenceAnimals(List<Animal> selected) async {
    for (var animal in selected) {
      await createFenceAnimal(
        FenceAnimalsCompanion(
          idFence: drift.Value(_selectedFence!.idFence),
          idAnimal: animal.animal.idAnimal,
        ),
      );
    }
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
                                                        _loadFenceAnimals();
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
                if (isInteractingFence)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20, right: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      localizations.animals.capitalizeFirst!,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isInteractingFence = false;
                                            _selectedFence = null;
                                          });
                                        },
                                        icon: const Icon(Icons.close),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: _onAddAnimals,
                                icon: Icon(
                                  Icons.add,
                                  color: theme.colorScheme.secondary,
                                ),
                                label: Text(
                                  '${localizations.add.capitalizeFirst!} ${localizations.devices.capitalizeFirst!}',
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: ListView.builder(
                                key: Key('$_fenceAnimals'),
                                itemCount: _fenceAnimals.length,
                                itemBuilder: (context, index) => AnimalItemRemovable(
                                  key: Key(_fenceAnimals[index].animal.idAnimal.value.toString()),
                                  animal: _fenceAnimals[index],
                                  onRemoveDevice: () => _onRemoveDevice(index),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  key: _mapParentKey,
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
                              parent: _mapParentKey,
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
