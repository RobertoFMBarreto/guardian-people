import 'dart:convert';
import 'dart:io';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/app_settings.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

/// This class is the provider of animals from the guardian api
class AnimalProvider {
  /// Method that calls the api to get all user animals
  static Future<Response> getAnimals() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/animals');
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

  /// Method that calls the api to get all user animals with last location
  static Future<Response> getAnimalsWithLastLocation() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/animals/location');
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

  /// Method that calls the api to get all animal data [idAnimal] between [startDate] and [endDate]
  static Future<Response> getAnimalData(
      String idAnimal, DateTime startDate, DateTime endDate) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/animals/$idAnimal');
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

  /// Method that calls the api to start the realtime streaming for the animal [idAnimal]
  static Future<Response> startRealtimeStreaming(String idAnimal) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    //f0634838-b721-4eda-8868-dc4973c8daac
    var url = Uri.http(kGDapiServerUrl, '/api/v1/animals/locations/subscription/$idAnimal/start');
    try {
      var response = await get(url, headers: headers);

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  ///  Method that calls the api to stop the realtime streaming for the animal [idAnimal]
  static Future<Response> stopRealtimeStreaming(String idAnimal) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/animals/locations/subscription/$idAnimal/cancel');
    try {
      var response = await get(url, headers: headers);

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method that calls the api to update the animal [animal]
  static Future<Response> updateAnimal(AnimalCompanion animal) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/animals/');
    try {
      var response = await put(
        url,
        headers: headers,
        body: jsonEncode({
          "idAnimal": animal.idAnimal.value,
          "animalName": animal.animalName.value,
          "animalColor": animal.animalColor.value,
        }),
      );

      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }
}
