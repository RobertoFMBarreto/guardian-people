import 'package:flutter/material.dart';
import 'package:guardian/routes.dart';

class CustomPageRouter extends MaterialPageRoute {
  final String page;
  CustomPageRouter({
    required this.page,
    RouteSettings? settings,
  }) : super(builder: (context) => routes[page]!(context), settings: settings);
}
