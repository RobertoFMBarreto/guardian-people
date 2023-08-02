import 'package:flutter/material.dart';

class CustomSTopBar extends StatelessWidget {
  double extent;
  String name;
  String imageUrl;
  CustomSTopBar({
    required this.extent,
    required this.name,
    required this.imageUrl,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    ThemeData theme = Theme.of(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
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
                    name,
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
          : FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: deviceWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.logout,
                            size: 25,
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 60 * (1 - (extent / 100)),
                  ),
                  Text(
                    name,
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
            ),
    );
  }
}
