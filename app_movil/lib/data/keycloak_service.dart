// Web usa redirección del navegador; Android/iOS usan AppAuth (PKCE).
export 'keycloak_service_mobile.dart'
    if (dart.library.html) 'keycloak_service_web.dart';
