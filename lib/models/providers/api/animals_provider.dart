import 'dart:io';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:http/http.dart';

/// This class is the provider of animals from the guardian api
class AnimalProvider {
  /// Method for getting all user animals from api
  static Future<Response> getAnimals() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http('192.168.10.71:7986', '/api/v1/animals');
    try {
      var response = await get(
        url,
        headers: headers,
      );
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method for getting all user animals from api with last location
  static Future<Response> getAnimalsWithLastLocation() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http('192.168.10.71:7986', '/api/v1/animals/location');
    try {
      var response = await get(
        url,
        headers: headers,
      );
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method for getting all animal data [idAnimal] between [startDate] and [endDate]
  static Future<Response> getAnimalData(
      String idAnimal, DateTime startDate, DateTime endDate) async {
    String? token = await getToken();
    Map<String, String> headers = {
      //HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http('192.168.10.71:7986', '/api/v1/animals/$idAnimal/data');
    try {
      var response = await post(url,
          headers: headers,
          body: {"startDate": startDate.toIso8601String(), "endDate": endDate.toIso8601String()});

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }
}
