import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/extensions/string_extension.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/device/device_item_removable.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  void initState() {
    super.initState();
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
        _points.addAll(fencePoints);
      });
    });
  }

  /// Method that loads all fence animals into the [_animals] list
  ///
  /// Resets the list to prevent duplicates
  Future<void> _loadAnimals() async {
    await getFenceAnimals(_fence.idFence).then(
      (allDevices) => setState(() {
        _animals = [];
        _animals.addAll(allDevices);
        _isLoading = false;
      }),
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
        for (var animal in selected) {
          await createFenceDevice(
            FenceAnimalsCompanion(
              idFence: drift.Value(_fence.idFence),
              idAnimal: animal.animal.idAnimal,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: !_isLoading
          ? AppBar(
              title: Text(
                '${localizations.fence.capitalize()} ${_fence.name}',
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
              actions: [
                if (hasConnection)
                  TextButton(
                    onPressed: () {
                      // TODO call service to delete fence
                      removeFence(_fence.idFence).then((_) => Navigator.of(context).pop());
                    },
                    child: Text(
                      localizations.remove.capitalize(),
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
                            child: DevicesLocationsMap(
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
                        child: Text('${localizations.edit.capitalize()} ${localizations.fence}'),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${localizations.associated_devices.capitalize()}:',
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
                            child: Text(localizations.no_selected_devices.capitalize()),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: ListView.builder(
                              itemCount: _animals.length,
                              itemBuilder: (context, index) => DeviceItemRemovable(
                                key: Key(_animals[index].animal.idAnimal.value.toString()),
                                animal: _animals[index],
                                onRemoveDevice: () {
                                  // TODO: On remove device
                                  removeAnimalFence(
                                          _fence.idFence, _animals[index].animal.idAnimal.value)
                                      .then(
                                    (_) {
                                      setState(() {
                                        _animals.removeWhere(
                                          (element) =>
                                              element.animal.idAnimal ==
                                              _animals[index].animal.idAnimal,
                                        );
                                      });
                                    },
                                  );
                                },
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
