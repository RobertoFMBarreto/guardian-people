import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:intl/intl.dart';

class DeviceDateCard extends StatelessWidget {
  final DateTime date;
  final Function() onTap;
  const DeviceDateCard({super.key, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Future.delayed(const Duration(milliseconds: 300)).then((value) => onTap());
        },
        splashFactory: InkSplash.splashFactory,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text(
                          '${date.day}',
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  DateFormat.MMMM(localizations.localeName)
                                      .format(date)
                                      .capitalize(),
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  '${date.year}',
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 0.1),
              Expanded(
                child: Center(
                  child: Text(
                    '${date.hour <= 9 ? "0${date.hour}" : date.hour}:${date.minute <= 9 ? "0${date.minute}" : date.minute}',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
