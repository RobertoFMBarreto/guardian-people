import 'package:flutter/material.dart';
import 'package:guardian/models/user.dart';

import '../../../producer.dart';

class Producers extends StatelessWidget {
  final List<User> producers;
  const Producers({super.key, required this.producers});

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
      itemCount: producers.length,
      itemBuilder: (context, index) => Producer(
        producerName: producers[index].name,
        devicesInfo: '10 dispositivos',
        imageUrl: '',
        uid: producers[index].uid,
      ),
    );
  }
}
