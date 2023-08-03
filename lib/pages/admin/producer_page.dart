import 'package:flutter/material.dart';
import 'package:guardian/models/models/custom_floating_btn_options.dart';
import 'package:guardian/widgets/device_item.dart';
import 'package:guardian/widgets/floating_action_button.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';

import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ProducerPage extends StatelessWidget {
  const ProducerPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
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
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: SearchFieldInput(label: 'Pesquisar'),
              ),
            ),
            SliverList.builder(
              itemCount: 20,
              itemBuilder: (context, index) => const DeviceItem(
                deviceImei: 999999999999999,
                deviceData: 10,
                deviceBattery: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
