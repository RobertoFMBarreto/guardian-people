import 'dart:convert';
import 'dart:io';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/app_settings.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

class FencingProvider {
  static Future<Response> createFence(
      FenceCompanion fence, FencePointsCompanion fencePoints) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.https(kGDapiServerUrl, '/api/v1/animals/');
    try {
      var response = await put(
        url,
        headers: headers,
        body: jsonEncode({
          "fenceName": fence.name,
          "fenceColor": fence.color,
          "isStayInside": true,
          "fencePoints": [
            {"lat": "string", "lon": "string", "isCenter": true}
          ]
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
