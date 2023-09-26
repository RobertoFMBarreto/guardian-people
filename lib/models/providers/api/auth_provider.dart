import 'dart:convert';
import 'dart:io';

import 'package:guardian/models/providers/session_provider.dart';
import 'package:http/http.dart';

class AuthProvider {
  static Future<Response> login(String email, String password) async {
    Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var url = Uri.http('192.168.10.71:7856', '/api/v1/login');

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

  static Future<Response> refreshToken() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http('192.168.10.71:7856', '/api/v1/session/refresh');
    try {
      var response = await get(url, headers: headers);

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }
}