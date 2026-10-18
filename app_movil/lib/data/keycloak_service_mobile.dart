import 'package:flutter_appauth/flutter_appauth.dart';
import '../core/environment_config.dart';

class KeycloakService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  // Debe coincidir con appAuthRedirectScheme (build.gradle.kts) y con el cliente en Keycloak
  static const String _redirectUrl = 'appmovil:/oauthredirect';

  /// Abre Keycloak en el navegador del teléfono y devuelve el access token.
  Future<String?> login() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          EnvironmentConfig.keycloakClientId,
          _redirectUrl,
          discoveryUrl:
              '${EnvironmentConfig.issuer}/.well-known/openid-configuration',
          scopes: ['openid', 'profile'],
          allowInsecureConnections: true, // solo laboratorio (HTTP)
        ),
      );
      return result.accessToken;
    } catch (e) {
      // ignore: avoid_print
      print('Error en KeycloakService: $e');
      return null;
    }
  }

  // En móvil el token llega directo en login(); no hay hash de URL que leer.
  String? checkForToken() => null;
}
