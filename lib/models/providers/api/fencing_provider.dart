import 'dart:convert';
import 'dart:io';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/app_settings.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

class FencingProvider {
  /// Method that allows to sendo the new fence to the api
  static Future<Response> createFence(
      FenceCompanion fence, List<FencePointsCompanion> fencePoints) async {
    String? token = await getToken();
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    var url = Uri.https(kGDapiServerUrl, '/api/v1/fences/');
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
}
