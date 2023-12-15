import 'dart:convert';
import 'dart:io';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/app_settings.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

/// This class is the provider of alerts from the guardian api
class AlertsProvider {
  /// Method that allows to get all alertable sensors
  static Future<Response> getAlertableSensors() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/sensors');
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

  /// Method for creating an alert
  static Future<Response> createAlert(UserAlertCompanion alert, List<Animal> animals) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/alerts');
    try {
      var response = await post(url,
          headers: headers,
          body: jsonEncode({
            "idConditionParameter": alert.parameter.value,
            "comparisson": alert.comparisson.value,
            "conditionCompTo": alert.conditionCompTo.value,
            "durationSeconds": alert.durationSeconds.value,
            "sendNotification": alert.hasNotification.value,
            "isTimed": alert.isTimed.value,
            "isStateParam": alert.isStateParam.value,
            "alertAnimals": animals.map((e) => e.animal.idAnimal.value).toList()
          }));
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method for updating an alert
  static Future<Response> updateAlert(UserAlertCompanion alert, List<Animal> animals) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/alerts/${alert.idAlert.value}');
    try {
      var response = await put(url,
          headers: headers,
          body: jsonEncode({
            "idConditionParameter": alert.parameter.value,
            "comparisson": alert.comparisson.value,
            "conditionCompTo": alert.conditionCompTo.value,
            "durationSeconds": alert.durationSeconds.value,
            "sendNotification": alert.hasNotification.value,
            "isTimed": alert.isTimed.value,
            "isStateParam": alert.isStateParam.value,
            "alertAnimals": animals.map((e) => e.animal.idAnimal.value).toList()
          }));
      return response;
    } on SocketException catch (e) {
      return Response(e.message, 507);
    } catch (e) {
      return Response('error', 507);
    }
  }

  /// Method that allows to get all user alerts
  static Future<Response> getAllAlerts() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/alerts');
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

  /// Method that allows to get all user alerts
  static Future<Response> deleteAlert(String alertId) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/alerts/$alertId');
    try {
      var response = await delete(
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
}
