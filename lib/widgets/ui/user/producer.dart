import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/custom_page_router.dart';

import 'circle_avatar_border.dart';

/// Class that represents a producer widget
class Producer extends StatelessWidget {
  final BigInt idUser;
  final String producerName;
  final String devicesInfo;
  final String imageUrl;
  const Producer({
    super.key,
    required this.producerName,
    required this.devicesInfo,
    required this.imageUrl,
    required this.idUser,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CustomPageRouter(page: '/admin/producer', settings: RouteSettings(arguments: idUser)),
      ),
      child: Container(
        height: 150,
        constraints: const BoxConstraints(
          minWidth: 200,
          maxWidth: 200,
          minHeight: 150,
          maxHeight: 150,
        ),
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
                  child: Container(
                    height: 110,
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 200,
                    ),
                    child: Card(
                      child: Padding(
                          padding:
                              const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                producerName,
                                style: theme.textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                devicesInfo,
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
              ),
              const CircleAvatarBorder(
                radius: 45,
              )
            ],
          ),
        ),
      ),
    );
  }
}
