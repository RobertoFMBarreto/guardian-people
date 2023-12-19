// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

/// Method that allows to get refresh token cookie from response in mobile
String getRefreshCookie(Response resp) => resp.headers['set-cookie']!.split('=')[1].split(';')[0];
