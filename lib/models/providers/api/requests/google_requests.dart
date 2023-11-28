import 'package:get/get.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';

class GoogleRequests {
  static Future<void> getSessionToken() async {
    AuthProvider.getGoogleMapsSessionToken().then((response) => print(response.body));
  }
}
