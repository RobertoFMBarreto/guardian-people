// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

String getRefreshCookie(Response resp) => resp.headers['set-cookie']!.split('=')[1].split(';')[0];
