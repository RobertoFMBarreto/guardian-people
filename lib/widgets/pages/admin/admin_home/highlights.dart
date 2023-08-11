import 'package:flutter/material.dart';
import 'package:guardian/models/user.dart';

import '../../../producer.dart';

class Highlights extends StatelessWidget {
  final List<User> users;
  const Highlights({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 8.0,
          top: 8.0,
          left: 10.0,
          right: 10.0,
        ),
        child: SizedBox(
          height: deviceHeight * 0.23,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) => Producer(
              producerName: users[index].name,
              devicesInfo: '2 dispositivos em alerta vermelho',
              imageUrl: '',
              uid: users[index].uid,
            ),
          ),
        ),
      ),
    );
  }
}
