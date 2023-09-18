import 'dart:convert';
import 'dart:io';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:http/http.dart' as http;

class AnimalProvider {
  static Future<http.Response> getAnimals() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http('localhost:7856', '/api/v1/animals');

    var response = await http.get(
      url,
      headers: headers,
    );
    return response;
  }
}
