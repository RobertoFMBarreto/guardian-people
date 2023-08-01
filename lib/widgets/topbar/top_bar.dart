import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  double extent;
  TopBar({required this.extent, super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    print(extent);
    ThemeData theme = Theme.of(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color.fromRGBO(88, 200, 160, 1),
            Color.fromRGBO(147, 215, 166, 1),
          ],
        ),
      ),
      child: extent >= 70
          ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Nome Produtor',
                    style:
                        theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSecondary),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 25,
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.menu,
                        color: theme.colorScheme.onSecondary,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 60 * (1 - (extent / 100)),
                ),
                Text(
                  'Nome Produtor',
                  style: theme.textTheme.headlineMedium!
                      .copyWith(color: theme.colorScheme.onSecondary),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: deviceHeight * 0.08,
                  ),
                )
              ],
            ),
    );
  }
}
