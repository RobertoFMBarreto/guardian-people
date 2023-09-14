import 'dart:convert';
import 'dart:io';

import 'package:guardian/models/providers/session_provider.dart';
import 'package:http/http.dart' as http;

class AuthProvider {
  static Future<http.Response> login(String email, String password) async {
    Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var url = Uri.http('localhost:7856', '/api/v1/login');

    Map<String, dynamic> body = {"email": email, "password": password};

    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    return response;
  }

  static Future<http.Response> refreshToken() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http('localhost:7856', '/api/v1/session/refresh');

    var response = await http.get(url, headers: headers);

    return response;
  }
}
