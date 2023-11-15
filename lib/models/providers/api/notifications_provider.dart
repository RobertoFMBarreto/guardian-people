import 'dart:io';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/app_settings.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

/// This class is the provider of notifications from the guardian api
class NotificationsProvider {
  /// Method that allows to get notifications from the api
  static Future<Response> getNotifications() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/notifications');
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

  /// Method that allows to get notifications from the api
  static Future<Response> deleteAllNotifications() async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/notifications');
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

  /// Method that allows to get notifications from the api
  static Future<Response> deleteNotification(String idNotification) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.http(kGDapiServerUrl, '/api/v1/notifications/$idNotification');
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
