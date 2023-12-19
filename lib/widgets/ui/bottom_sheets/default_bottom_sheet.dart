import 'package:flutter/material.dart';

/// Class that representss the default bottom sheet
class DefaultBottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> body;
  final CrossAxisAlignment bodyCrossAxisAlignment;
  const DefaultBottomSheet({
    super.key,
    required this.title,
    required this.body,
    this.bodyCrossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 2,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 20.0),
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: bodyCrossAxisAlignment,
                  children: [...body],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
