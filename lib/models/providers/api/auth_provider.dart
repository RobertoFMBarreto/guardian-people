import 'dart:convert';
import 'dart:io';

import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/app_settings.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

/// This class is the authentication provider
class AuthProvider {
  /// Method for login based on [email] and [password]
  static Future<Response> login(String email, String password) async {
    Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var url = Uri.http(kGDapiServerUrl, '/api/v1/login');

    Map<String, dynamic> body = {"email": email, "password": password};
    try {
      var response = await post(url, headers: headers, body: jsonEncode(body));

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method for refresh user session token
  static Future<Response> refreshToken() async {
    String? token = await getRefreshToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/refresh-token');
    try {
      var response = await post(url, headers: headers, body: jsonEncode({"refreshToken": token}));

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method for refresh user session token
  static Future<Response> refreshDeviceToken(String deviceToken) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/user/device/token');
    try {
      var response =
          await post(url, headers: headers, body: jsonEncode({"deviceToken": deviceToken}));

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }
}
