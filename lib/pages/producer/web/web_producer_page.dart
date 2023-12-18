import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/pages/producer/web/web_producer_alerts_page.dart';
import 'package:guardian/pages/producer/web/web_producer_device_page.dart';
import 'package:guardian/pages/producer/web/web_producer_fences_page.dart';
import 'package:guardian/pages/producer/web/web_producer_home_page.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/ui/user/circle_avatar_border.dart';

class WebProducerPage extends StatefulWidget {
  const WebProducerPage({super.key});

  @override
  State<WebProducerPage> createState() => _WebProducerPageState();
}

class _WebProducerPageState extends State<WebProducerPage> {
  late Widget _currentPage;
  Animal? _selectedAnimal;
  int _selectedDestination = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    pages = [
      WebProducerHomePage(
        onSelectAnimal: (animal) {
          setState(() {
            _selectedAnimal = animal;
            _selectedDestination = 2;
          });
        },
      ),
      const Placeholder(),
      const WebProducerDevicePage(),
      const WebProducerFencesPage(),
      const WebProducerAlertsPage(),
    ];
    goToPage(0);

    super.initState();
  }

  /// Method that replaces the current page on screen sending the needed data to it
  void goToPage(int index) {
    setState(() {
      _selectedDestination = index;
    });

    _currentPage = pages[index];
    switch (index) {
      case 0:
        _currentPage = WebProducerHomePage(
          onSelectAnimal: (animal) {
            setState(() {
              _selectedAnimal = animal;
            });
            goToPage(2);
            _selectedAnimal = null;
          },
        );
      case 1:
        _currentPage = pages[1];
      case 2:
        _currentPage = WebProducerDevicePage(
          selectedAnimal: _selectedAnimal,
        );
      case 3:
        _currentPage = pages[3];
      case 4:
        _currentPage = pages[4];
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Row(
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
                    goToPage(value);
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
              child: _currentPage,
            )
          ],
        ),
      ),
    );
  }
}
