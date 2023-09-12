import 'package:flutter/material.dart';
import 'package:guardian/main.dart';

class FenceItem extends StatelessWidget {
  final String name;
  final Color color;
  final Function() onRemove;
  final Function() onTap;

  const FenceItem({
    super.key,
    required this.onRemove,
    required this.name,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () {
          Future.delayed(const Duration(milliseconds: 300)).then((value) => onTap());
        },
        borderRadius: BorderRadius.circular(10),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: color,
                  width: 10,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 15, right: 8.0, top: 8.0, bottom: 8.0),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    name,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (hasConnection)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_forever),
                    iconSize: 30,
                    color: theme.colorScheme.error,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
