import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/routes/mobile_routes.dart';
import 'package:guardian/routes/web_routes.dart';

/// Class that represents custom router information
class CustomPageRouter extends MaterialPageRoute {
  final String page;
  CustomPageRouter({
    required this.page,
    RouteSettings? settings,
  }) : super(builder: (context) => mobileRoutes[page]!(context), settings: settings);
}
