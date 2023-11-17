import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/admin/admin_devices_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/widgets/ui/animal/animal_item.dart';
import 'package:guardian/widgets/ui/animal/option_button.dart';
import 'package:guardian/widgets/ui/topbars/device_topbar/sliver_device_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminDeviceManagementPage extends StatefulWidget {
  final Animal device;
  final String producerId;

  const AdminDeviceManagementPage({
    super.key,
    required this.device,
    required this.producerId,
  });

  @override
  State<AdminDeviceManagementPage> createState() => _AdminDeviceManagementPageState();
}

class _AdminDeviceManagementPageState extends State<AdminDeviceManagementPage> {
  late Animal _animal;
  late Future _future;

  final List<Animal> _animals = [];

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    _animal = widget.device;
    await _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    await getProducerAnimals(widget.producerId).then((allAnimals) {
      if (mounted) {
        setState(() {
          _animals.addAll(
              allAnimals.where((element) => element.animal.idAnimal != _animal.animal.idAnimal));
        });
      }
    });
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
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverDeviceAppBar(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                      isWhiteBody: true,
                      leadingWidget: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.colorScheme.onSecondary,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      device: _animal,
                    ),
                  ),
                  if (hasConnection)
                    OptionButton(
                      key: Key(_animal.animal.isActive.value.toString()),
                      animal: _animal,
                      onRemove: () {
                        //TODO: Remove device
                        deleteAnimal(_animal.animal.idAnimal.value).then((_) {
                          Navigator.of(context).pop();
                        });
                      },
                      onBlock: () {
                        //TODO: block device

                        final newAnimal = _animal.animal
                            .copyWith(isActive: drift.Value(!_animal.animal.isActive.value));
                        updateAnimal(newAnimal).then((_) {
                          setState(
                            () {
                              _animal = Animal(animal: newAnimal, data: _animal.data);
                            },
                          );
                        });
                      },
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      child: Text(
                        '${localizations.other_producer_devices.capitalizeFirst!}:',
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (_animals.isEmpty)
                    SliverFillRemaining(
                      child: Center(child: Text(localizations.no_devices.capitalizeFirst!)),
                    ),
                  if (_animals.isNotEmpty)
                    SliverFillRemaining(
                      child: ListView.builder(
                        itemCount: _animals.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: AnimalItem(
                            animal: _animals[index],
                            deviceStatus: _animals[index].deviceStatus!,
                            producerId: widget.producerId,
                          ),
                        ),
                      ),
                    )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
