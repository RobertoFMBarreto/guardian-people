import 'dart:html';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

String getRefreshCookie(Response _) => document.cookie!.split('=')[1].split(';')[0];
