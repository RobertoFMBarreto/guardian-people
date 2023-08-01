import 'package:flutter/material.dart';

import '../../../producer.dart';

class Highlights extends StatelessWidget {
  const Highlights({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Destaques',
              style: theme.textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 8.0,
              top: 8.0,
              left: 10.0,
              right: 10.0,
            ),
            child: SizedBox(
              height: deviceHeight * 0.25,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) => Producer(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
