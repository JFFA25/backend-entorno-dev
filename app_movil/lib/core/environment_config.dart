class EnvironmentConfig {
  // Una sola URL pública (IP de tu PC en la red, no localhost, si pruebas en el teléfono).
  // Se inyecta al compilar: --dart-define=PUBLIC_BASE_URL=http://192.168.1.50:8085
  static const String publicBaseUrl = String.fromEnvironment(
    'PUBLIC_BASE_URL',
    defaultValue: 'http://localhost:8085',
  );

  // Nginx reenvía /api -> FastAPI y /auth -> Keycloak
  static const String apiBaseUrl = '$publicBaseUrl/api';
  static const String keycloakUrl = '$publicBaseUrl/auth';

  static const String keycloakRealm = String.fromEnvironment(
    'KEYCLOAK_REALM',
    defaultValue: 'app-movil',
  );

  static const String keycloakClientId = String.fromEnvironment(
    'KEYCLOAK_CLIENT_ID',
    defaultValue: 'flutter-app',
  );

  static const String issuer = '$keycloakUrl/realms/$keycloakRealm';
}
