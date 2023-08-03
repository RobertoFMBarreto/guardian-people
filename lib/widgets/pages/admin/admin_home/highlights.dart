import 'package:flutter/material.dart';

import '../../../producer.dart';

class Highlights extends StatelessWidget {
  const Highlights({super.key});

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
            itemCount: 10,
            itemBuilder: (context, index) => Producer(),
          ),
        ),
      ),
    );
  }
}
