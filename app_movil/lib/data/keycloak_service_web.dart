// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../core/environment_config.dart';

class KeycloakService {
  final String _authUri =
      '${EnvironmentConfig.keycloakUrl}/realms/${EnvironmentConfig.keycloakRealm}/protocol/openid-connect/auth';
  final String _clientId = EnvironmentConfig.keycloakClientId;

  final String _redirectUri = '${html.window.location.origin}/';

  Future<String?> login() async {
    final url = '$_authUri'
        '?client_id=$_clientId'
        '&redirect_uri=${Uri.encodeComponent(_redirectUri)}'
        '&response_type=token'
        '&scope=openid%20profile';

    html.window.location.href = url;
    return null;
  }

  String? checkForToken() {
    final hash = html.window.location.hash;
    if (hash.contains('access_token=')) {
      final params = Uri.splitQueryString(hash.substring(1));
      return params['access_token'];
    }
    return null;
  }
}
