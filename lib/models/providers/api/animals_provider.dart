import 'dart:convert';
import 'dart:io';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/app_settings.dart';
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
    var url = Uri.https(kGDapiServerUrl, '/api/v1/animals');
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
    var url = Uri.https(kGDapiServerUrl, '/api/v1/animals/location');
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
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.https(kGDapiServerUrl, '/api/v1/animals/$idAnimal');
    try {
      var response = await post(url,
          headers: headers,
          body: jsonEncode(
              {"startDate": startDate.toIso8601String(), "endDate": endDate.toIso8601String()}));

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method that enables the realtime straming for the animal [idAnimal]
  static Future<Response> startRealtimeStreaming(String idAnimal) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url =
        Uri.https(kGDapiServerUrl, '/api/v1/animals/animal/locations/subscription/$idAnimal/start');
    try {
      var response = await get(url, headers: headers);

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method that stops the realtime straming for the animal [idAnimal]
  static Future<Response> stopRealtimeStreaming(String idAnimal) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.https(
        kGDapiServerUrl, '/api/v1/animals/animal/locations/subscription/$idAnimal/cancel');
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
