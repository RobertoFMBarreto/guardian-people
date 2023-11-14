import 'package:flutter/material.dart';
import 'package:guardian/pages/login_page.dart';
import 'package:guardian/pages/producer/web/web_producer_device_page.dart';
import 'package:guardian/pages/producer/web/web_producer_page.dart';

Map<String, Widget Function(BuildContext)> webRoutes = {
  '/': (context) => const LoginPage(),
  '/login': (context) => const LoginPage(),
  '/producer': (context) => const WebProducerPage(),
  '/producer/device': (context) => const WebProducerDevicePage(),
};
