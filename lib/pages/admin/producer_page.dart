import 'package:flutter/material.dart';
import 'package:guardian/models/models/custom_floating_btn_options.dart';
import 'package:guardian/models/models/device.dart';
import 'package:guardian/models/models/devices.dart';
import 'package:guardian/models/models/focus_manager.dart';
import 'package:guardian/widgets/device_item.dart';
import 'package:guardian/widgets/floating_action_button.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';

import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class ProducerPage extends StatefulWidget {
  const ProducerPage({super.key});

  @override
  State<ProducerPage> createState() => _ProducerPageState();
}

class _ProducerPageState extends State<ProducerPage> {
  List<Device> devices = const [
    Device(imei: 999999999999999, dataUsage: 10, battery: 80),
    Device(imei: 999999999999998, dataUsage: 9, battery: 50),
    Device(imei: 999999999999997, dataUsage: 8, battery: 75),
    Device(imei: 999999999999996, dataUsage: 7, battery: 60),
    Device(imei: 999999999999995, dataUsage: 6, battery: 90),
    Device(imei: 999999999999994, dataUsage: 5, battery: 5),
    Device(imei: 999999999999993, dataUsage: 4, battery: 15),
    Device(imei: 999999999999992, dataUsage: 3, battery: 26),
    Device(imei: 999999999999991, dataUsage: 2, battery: 40),
    Device(imei: 999999999999990, dataUsage: 1, battery: 61),
  ];

  List<Device> backupDevices = [];

  @override
  void initState() {
    // backup all devices
    backupDevices.addAll(devices);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
        floatingActionButton: CustomFloatingActionButton(
          options: [
            CustomFloatingActionButtonOption(
              title: 'Adicionar Dispositivo',
              icon: Icons.add,
              onTap: () {
                //!TODO: code for add device
              },
            ),
            CustomFloatingActionButtonOption(
              title: 'Remover Dispositivo',
              icon: Icons.remove,
              onTap: () {
                //!TODO: code for remove device
              },
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverMainAppBar(
                  imageUrl: '',
                  name: 'Nome Produtor',
                  title: Text(
                    'Dispositivos',
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                  tailWidget: IconButton(
                    icon: Icon(
                      Icons.delete_forever,
                      color: theme.colorScheme.onSecondary,
                      size: 30,
                    ),
                    onPressed: () {
                      //!TODO: Code for deleting the producer
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: SearchFieldInput(
                    label: 'Pesquisar',
                    onChanged: (searchString) {
                      setState(() {
                        devices = Devices.searchDevice(searchString, backupDevices);
                      });
                    },
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) => DeviceItem(
                  deviceImei: devices[index].imei,
                  deviceData: devices[index].dataUsage,
                  deviceBattery: devices[index].battery,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
