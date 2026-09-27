import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/environment_config.dart';

class ApiService {
  // Consume la URL base de tu archivo de ambientes
  final String _baseUrl = EnvironmentConfig.apiBaseUrl;

  Future<Map<String, dynamic>> getDatabaseHealth() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/healthcheck'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"error": "Error del servidor: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "No se pudo conectar al backend: $e"};
    }
  }
}
