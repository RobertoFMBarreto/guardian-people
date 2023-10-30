import 'dart:io';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/app_settings.dart';
import 'package:http/http.dart';

class NotificationsProvider {
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
}
