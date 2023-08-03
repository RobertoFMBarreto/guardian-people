import 'package:flutter/material.dart';

import '../../../producer.dart';

class Producers extends StatelessWidget {
  const Producers({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        mainAxisExtent: deviceHeight * 0.23,
      ),
      itemCount: 10,
      itemBuilder: (context, index) => const Producer(
        producerName: 'Nome Produtor',
        devicesInfo: '10 dispositivos',
        imageUrl: '',
      ),
    );
  }
}
