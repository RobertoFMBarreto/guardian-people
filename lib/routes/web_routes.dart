import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:guardian/pages/login_page.dart';
import 'package:guardian/pages/producer/web/web_producer_device_page.dart';
import 'package:guardian/pages/producer/web/web_producer_page.dart';
import 'package:guardian/pages/welcome_page.dart';

Map<String, Widget Function(BuildContext)> webRoutes = {
  '/': (context) => isBigScreen ? const WelcomePage() : const LoginPage(),
  '/login': (context) => const LoginPage(),
  '/producer': (context) => const WebProducerPage(),
  '/producer/device': (context) => const WebProducerDevicePage(),
};
