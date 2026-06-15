import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static String get baseUrl => ApiConstants.baseUrl;

  // --- HELPER PARA IMÁGENES ---
  static String getFullUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://cdn-icons-png.flaticon.com/512/3081/3081986.png';
    if (path.startsWith('http')) return path;
    
    // Si es una ruta relativa del backend (ej: /uploads/products/xxx.jpg)
    // El baseUrl suele terminar en /api, así que hay que tener cuidado
    String base = baseUrl.replaceAll('/api', '');
    return '$base$path';
  }

  // --- FUNCIÓN PRIVADA PARA OBTENER EL TOKEN ---
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. Petición GET con Token
  static Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      
      String cleanEndpoint = endpoint;
      if (endpoint.startsWith('/api/')) {
        cleanEndpoint = endpoint.substring(4);
      } else if (endpoint.startsWith('api/')) {
        cleanEndpoint = endpoint.substring(3);
      }
      
      final url = cleanEndpoint.startsWith('/') ? '$baseUrl$cleanEndpoint' : '$baseUrl/$cleanEndpoint';
      print('📡 ApiService GET: $url');
      
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

  // 2. Petición POST con Token
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      
      String cleanEndpoint = endpoint;
      if (endpoint.startsWith('/api/')) {
        cleanEndpoint = endpoint.substring(4);
      } else if (endpoint.startsWith('api/')) {
        cleanEndpoint = endpoint.substring(3);
      }

      final url = cleanEndpoint.startsWith('/') ? '$baseUrl$cleanEndpoint' : '$baseUrl/$cleanEndpoint';
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

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
      
      String cleanEndpoint = endpoint;
      if (endpoint.startsWith('/api/')) {
        cleanEndpoint = endpoint.substring(4);
      } else if (endpoint.startsWith('api/')) {
        cleanEndpoint = endpoint.substring(3);
      }

      final url = cleanEndpoint.startsWith('/') ? '$baseUrl$cleanEndpoint' : '$baseUrl/$cleanEndpoint';
      
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

  // 4. Petición DELETE con Token
  static Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      
      String cleanEndpoint = endpoint;
      if (endpoint.startsWith('/api/')) {
        cleanEndpoint = endpoint.substring(4);
      } else if (endpoint.startsWith('api/')) {
        cleanEndpoint = endpoint.substring(3);
      }

      final url = cleanEndpoint.startsWith('/') ? '$baseUrl$cleanEndpoint' : '$baseUrl/$cleanEndpoint';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR HTTP DELETE ($endpoint): $e');
      throw Exception('Error de conexión');
    }
  }

  // 5. Petición PATCH con Token
  static Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      
      String cleanEndpoint = endpoint;
      if (endpoint.startsWith('/api/')) {
        cleanEndpoint = endpoint.substring(4);
      } else if (endpoint.startsWith('api/')) {
        cleanEndpoint = endpoint.substring(3);
      }

      final url = cleanEndpoint.startsWith('/') ? '$baseUrl$cleanEndpoint' : '$baseUrl/$cleanEndpoint';
      
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
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

  // 5. SUBIDA DE IMÁGENES (MultiPart)
  static Future<String> uploadImage(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/imagenes/upload'));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        filePath,
        contentType: MediaType('image', 'jpeg'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body; 
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al subir: $e');
    }
  }
}
