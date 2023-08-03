import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';

import 'circle_avatar_border.dart';

class Producer extends StatelessWidget {
  const Producer({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/admin/producer'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                elevation: 5,
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
                child: SizedBox(
                  height: 110,
                  width: 0.43 * deviceWidth,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Nome Produtor',
                            style: theme.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '2 dispositivos em alerta vermelho',
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: gdSecondaryTextColor,
                              fontSize: 15,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )),
                ),
              ),
            ),
            const CircleAvatarBorder(
              radius: 50,
            )
          ],
        ),
      ),
    );
  }
}
