import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  static String get baseUrl => ApiConstants.baseUrl;

  // --- FUNCIÓN PRIVADA PARA OBTENER EL TOKEN ---
  // Esto evita repetir código en cada método
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // O 'jwt_token', como lo guardaras en el AuthProvider

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. Petición GET con Token
  static Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('/') ? '$baseUrl$endpoint' : '$baseUrl/$endpoint';
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 2. Petición POST con Token (Aquí fallaba la venta)
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('/') ? '$baseUrl$endpoint' : '$baseUrl/$endpoint';
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      // Aceptamos 200 (OK) y 201 (Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 403) {
        throw Exception('Error 403: No tienes permisos o el token expiró.');
      } else {
        throw Exception('Error al guardar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 3. Petición PUT con Token
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('/') ? '$baseUrl$endpoint' : '$baseUrl/$endpoint';
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al actualizar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR HTTP PUT ($endpoint): $e');
      throw Exception('Error de conexión');
    }
  }

  // 4. Petición PATCH con Token
  static Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('/') ? '$baseUrl$endpoint' : '$baseUrl/$endpoint';
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body), // Si no envías body, enviar un mapa vacío {} está perfecto
      );

      // Aceptamos 200 (OK) o 204 (No Content) dependiendo de cómo lo devuelva tu Spring Boot
      if (response.statusCode == 200 || response.statusCode == 204) {
        // A veces PATCH devuelve el objeto modificado o a veces no devuelve nada.
        // Si tu backend no devuelve un JSON (ej. cuerpo vacío), esto podría dar error al decodificar.
        if (response.body.isNotEmpty) {
          return json.decode(utf8.decode(response.bodyBytes));
        }
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Error 403: No tienes permisos.');
      } else {
        throw Exception('Error al modificar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR HTTP PATCH ($endpoint): $e');
      throw Exception('Error de conexión: $e');
    }
  }

}