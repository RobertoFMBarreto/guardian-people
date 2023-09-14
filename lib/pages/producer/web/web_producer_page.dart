import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/pages/producer/web/web_producer_device_page.dart';
import 'package:guardian/pages/producer/web/web_producer_home_page.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/ui/user/circle_avatar_border.dart';

class WebProducerPage extends StatefulWidget {
  const WebProducerPage({super.key});

  @override
  State<WebProducerPage> createState() => _WebProducerPageState();
}

class _WebProducerPageState extends State<WebProducerPage> {
  int _selectedDestination = 0;
  List<Widget> pages = [
    const WebProducerHomePage(),
    Placeholder(),
    const WebProducerDevicePage(),
    Placeholder(),
    Placeholder(),
  ];
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.brightness == Brightness.dark ? gdDarkGradientStart : gdGradientStart,
                    theme.brightness == Brightness.dark ? gdDarkGradientEnd : gdGradientEnd,
                  ],
                ),
              ),
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                onDestinationSelected: (value) {
                  setState(() {
                    _selectedDestination = value;
                  });
                },
                leading: const CircleAvatarBorder(
                  radius: 30,
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('First'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    selectedIcon: Icon(Icons.account_circle),
                    label: Text('First'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.sensors),
                    selectedIcon: Icon(Icons.sensors),
                    label: Text('First'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.fence),
                    selectedIcon: Icon(Icons.fence),
                    label: Text('First'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.warning_amber_sharp),
                    selectedIcon: Icon(Icons.warning_outlined),
                    label: Text('First'),
                  ),
                ],
                selectedIndex: _selectedDestination,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: pages[_selectedDestination],
            ),
          )
        ],
      ),
    );
  }
}
