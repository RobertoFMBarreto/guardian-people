import 'dart:convert';
import 'dart:io';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/app_settings.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

/// This class is the provider of fencing from the guardian api
class FencingProvider {
  /// Method that calls the api to create a fence with [fence] and [fencePoints]
  static Future<Response> createFence(
      FenceCompanion fence, List<FencePointsCompanion> fencePoints) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/fences/');
    try {
      final body = jsonEncode({
        "idFence": fence.idFence.value,
        "fenceName": fence.name.value,
        "fenceColor": fence.color.value,
        "isStayInside": fence.isStayInside.value,
        "fencePoints": fencePoints
            .map(
              (e) => {
                "lat": e.lat.value.toString(),
                "lon": e.lon.value.toString(),
                "isCenter": e.isCenter.value,
              },
            )
            .toList()
      });
      var response = await post(url, headers: headers, body: body);
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method that calls the api to remove a fence from the api
  static Future<Response> removeFence(String idFence) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/fences/$idFence');
    try {
      var response = await delete(url, headers: headers);
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method that calls the api to get all user fences
  static Future<Response> getUserFences() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/fences');
    try {
      var response = await get(url, headers: headers);
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method that calls the api to update a fence with [fence] and [fencePoints]
  static Future<Response> updateFence(
      FenceCompanion fence, List<FencePointsCompanion> fencePoints) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/fences/');
    try {
      final body = jsonEncode({
        "idFence": fence.idFence.value,
        "fenceName": fence.name.value,
        "fenceColor": fence.color.value,
        "isStayInside": fence.isStayInside.value,
        "fencePoints": fencePoints
            .map(
              (e) => {
                "lat": e.lat.value.toString(),
                "lon": e.lon.value.toString(),
                "isCenter": e.isCenter.value,
              },
            )
            .toList()
      });
      var response = await put(url, headers: headers, body: body);
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method that calls the api to add animals [animalsIds] to a fence [fenceId]
  static Future<Response> addAnimalFence(String fenceId, List<String> animalIds) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/fences/$fenceId/animals');
    try {
      var response = await post(url, headers: headers, body: jsonEncode(animalIds));
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method that calls the api to remove animals [animalIds] from the fence [fenceId]
  static Future<Response> removeAnimalFence(String fenceId, List<String> animalIds) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/fences/$fenceId/animals');
    try {
      var response = await delete(url, headers: headers, body: jsonEncode(animalIds));
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }
}
