import 'dart:io';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:http/http.dart' as http;

String getTimezone(Duration offset) =>
    "${offset.isNegative ? "-" : "+"}${offset.inHours.abs().toString().padLeft(2, "0")}:${(offset.inMinutes - offset.inHours * 60).abs().toString().padLeft(2, "0")}";

class AnimalProvider {
  static Future<http.Response> getAnimals() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http('192.168.10.71:7856', '/api/v1/animals');

    var response = await http.get(
      url,
      headers: headers,
    );
    return response;
  }

  static Future<http.Response> getAnimalData(
      BigInt idAnimal, DateTime startDate, DateTime endDate) async {
    String? token = await getToken();
    Map<String, String> headers = {
      //HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http('192.168.10.71:7856', '/api/v1/animals/$idAnimal/data');
    var response = await http.post(url,
        headers: headers,
        body: {"startDate": startDate.toIso8601String(), "endDate": endDate.toIso8601String()});

    return response;
  }
}
