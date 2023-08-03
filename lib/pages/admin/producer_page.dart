import 'package:flutter/material.dart';
import 'package:guardian/widgets/producer.dart';

import '../../widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class ProducerPage extends StatelessWidget {
  const ProducerPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverMainAppBar(
                imageUrl: '',
                name: 'Nome Produtor',
                title: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Dispositivos',
                      style: theme.textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
            // SliverToBoxAdapter(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.only(
            //           bottom: 8.0,
            //           top: 8.0,
            //           left: 10.0,
            //           right: 10.0,
            //         ),
            //         child: SizedBox(
            //           height: deviceHeight * 0.23,
            //           child: ListView.builder(
            //             itemCount: 10,
            //             itemBuilder: (context, index) => Producer(),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
