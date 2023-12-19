// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

/// Method that allows to get a refresh cookie from response in web
String getRefreshCookie(Response _) => document.cookie!.split('=')[1].split(';')[0];
