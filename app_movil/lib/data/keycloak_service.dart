import 'dart:html' as html;
import '../core/environment_config.dart'; // 1. Importamos tu configurador de ambiente

class KeycloakService {
  // 2. Armamos la URL inyectando las variables de entorno de forma dinámica:
  final String _authUri = '${EnvironmentConfig.keycloakUrl}/realms/${EnvironmentConfig.keycloakRealm}/protocol/openid-connect/auth'; 
  final String _clientId = EnvironmentConfig.keycloakClientId;
  
  // Redirecciona al puerto actual de tu Flutter Web de forma dinámica
  final String _redirectUri = '${html.window.location.origin}/';

  Future<String?> login() async {
    try {
      // Construimos la URL de autenticación directa de Keycloak para la Web
      final url = '$_authUri'
          '?client_id=$_clientId'
          '&redirect_uri=${Uri.encodeComponent(_redirectUri)}'
          '&response_type=token'
          '&scope=openid%20profile';

      // Redirecciona la pestaña actual directamente a Keycloak
      html.window.location.href = url;
      return null;
    } catch (e) {
      print("Error en KeycloakService: $e");
      return null;
    }
  }

  // Función para capturar el Token que Keycloak regresa en la URL tras loguearse
  String? checkForToken() {
    final hash = html.window.location.hash;
    if (hash.contains('access_token=')) {
      final params = Uri.splitQueryString(hash.substring(1));
      return params['access_token'];
    }
    return null;
  }
}
