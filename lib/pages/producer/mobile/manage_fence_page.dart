import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/widgets/ui/animal/animal_item_removable.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Class that represents the manage fence page
class ManageFencePage extends StatefulWidget {
  final FenceData fence;

  const ManageFencePage({
    super.key,
    required this.fence,
  });

  @override
  State<ManageFencePage> createState() => _ManageFencePageState();
}

class _ManageFencePageState extends State<ManageFencePage> {
  List<Animal> _animals = [];
  List<LatLng> _points = [];

  late FenceData _fence;

  bool _isLoading = true;
  bool _firstRun = true;

  @override
  void initState() {
    super.initState();

    isSnackbarActive = false;
    _fence = widget.fence;
    _loadAnimals();
    _reloadFence();
  }

  /// Method that loads all fence points into the [_points] list
  ///
  /// Resets the list to prevent duplicates
  Future<void> _loadFencePoints() async {
    await getFencePoints(_fence.idFence).then((fencePoints) {
      setState(() {
        _points = [];
        _points.addAll(fencePoints.map((e) => LatLng(e.lat, e.lon)).toList());
      });
    });
  }

  /// Method that loads all fence animals into the [_animals] list
  ///
  /// Resets the list to prevent duplicates
  Future<void> _loadAnimals() async {
    await FencingRequests.getUserFences(
      context: context,
      onFailed: (statusCode) {
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
      },
      onGottenData: (data) async {
        await getFenceAnimals(_fence.idFence).then(
          (allDevices) => setState(() {
            _animals = [];
            _animals.addAll(allDevices);
            _isLoading = false;
          }),
        );
      },
    );
  }

  /// Method that reloads the fence replacing the [_fence] with the new fence from database
  Future<void> _reloadFence() async {
    await getFence(widget.fence.idFence).then((newFence) {
      setState(() => _fence = newFence);
    });
    _loadFencePoints();
  }

  /// Method that pushes to the devices page in select mode and loads the selected animals into the [_animals] list
  ///
  /// It also inserts in the database the connection between the animal and the fence
  Future<void> _selectAnimals() async {
    Navigator.push(
      context,
      CustomPageRouter(
          page: '/producer/devices',
          settings: RouteSettings(
            arguments: {
              'isSelect': true,
              'idFence': _fence.idFence,
            },
          )),
    ).then((selectedAnimals) async {
      if (selectedAnimals != null && selectedAnimals.runtimeType == List<Animal>) {
        final selected = selectedAnimals as List<Animal>;
        setState(() {
          _animals.addAll(selected);
        });
        _createFenceAnimals(selected).then(
          (_) => FencingRequests.addAnimalFence(
            fenceId: _fence.idFence,
            animalIds: selected.map((e) => e.animal.idAnimal.value).toList(),
            context: context,
            onFailed: (statusCode) {
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
          idFence: drift.Value(_fence.idFence),
          idAnimal: animal.animal.idAnimal,
        ),
      );
    }
  }

  Future<void> _onRemoveDevice(int index) async {
    //store the animal
    final animal = _animals[index];
    setState(() {
      _animals.removeWhere(
        (element) => element.animal.idAnimal == _animals[index].animal.idAnimal,
      );
    });
    FencingRequests.removeAnimalFence(
      animalIds: [animal.animal.idAnimal.value],
      context: context,
      fenceId: _fence.idFence,
      onDataGotten: () async {
        await removeAnimalFence(_fence.idFence, animal.animal.idAnimal.value);
      },
      onFailed: (statusCode) {
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
        setState(() {
          _animals.add(animal);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: !_isLoading
          ? AppBar(
              title: Text(
                '${localizations.fence.capitalizeFirst!} ${_fence.name}',
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
              actions: [
                if (hasConnection)
                  TextButton(
                    onPressed: () {
                      removeFence(_fence.idFence).then((_) => Navigator.of(context).pop());
                    },
                    child: Text(
                      localizations.remove.capitalizeFirst!,
                      style: theme.textTheme.bodyLarge!
                          .copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.w500),
                    ),
                  )
              ],
            )
          : null,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AnimalsLocationsMap(
                              key: Key('${_fence.color}$_points'),
                              showCurrentPosition: true,
                              animals: _animals,
                              centerOnPoly: true,
                              fences: [_fence],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasConnection)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed('/producer/geofencing', arguments: _fence)
                              .then(
                            (newPoints) {
                              if (newPoints != null && newPoints.runtimeType == List<LatLng>) {
                                setState(() {
                                  _points = newPoints as List<LatLng>;
                                });
                                _reloadFence();
                              }
                            },
                          );
                        },
                        child:
                            Text('${localizations.edit.capitalizeFirst!} ${localizations.fence}'),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${localizations.associated_devices.capitalizeFirst!}:',
                          style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (hasConnection)
                          IconButton(
                            onPressed: () async {
                              _selectAnimals();
                            },
                            icon: const Icon(Icons.add),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _animals.isEmpty
                        ? Center(
                            child: Text(localizations.no_selected_devices.capitalizeFirst!),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: ListView.builder(
                              itemCount: _animals.length,
                              itemBuilder: (context, index) => AnimalItemRemovable(
                                key: Key(_animals[index].animal.idAnimal.value.toString()),
                                animal: _animals[index],
                                onRemoveDevice: () => _onRemoveDevice(index),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
