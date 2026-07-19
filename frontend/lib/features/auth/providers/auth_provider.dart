import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String? _rol;
  String? _tienda;
  String? _tiendaSeleccionada;
  bool _isLoading = false;

  // Getters (para que la interfaz visual pueda leer estos datos)
  // Como _token ya no es nulo cuando inicias sesión, isAuthenticated se vuelve "true" automáticamente
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get username => _username;
  String? get rol => _rol;
  String? get tienda => _tienda;

  String get tiendaSeleccionada {
    if (_rol == 'ADMIN') {
      return _tiendaSeleccionada ?? 'ALL';
    }
    return _tienda ?? 'C1';
  }

  void setTiendaSeleccionada(String value) {
    _tiendaSeleccionada = value;
    notifyListeners();
  }

  // 1. REVISAR SI YA HAY SESIÓN GUARDADA
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(resp);

      if (map is Map && map.containsKey('exp')) {
        final exp = map['exp'] as int;
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return DateTime.now().isAfter(expiryDate);
      }
    } catch (e) {
      debugPrint("Error decoding token expiration: $e");
      return true;
    }
    return true;
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // OJO: Buscamos exactamente con la misma llave que usamos al guardar ('jwt_token')
    final token = prefs.getString('jwt_token');

    if (token != null && token.isNotEmpty) {
      if (isTokenExpired(token)) {
        await logout();
        return false; // El token expiró, forzar login
      }
      _token = token;
      _username = prefs.getString('username');
      _rol = prefs.getString('rol');
      _tienda = prefs.getString('tienda');

      notifyListeners();
      return true; // Sí encontró la sesión y es válida
    }
    return false; // No hay sesión, debe ir al login
  }

  // 2. FUNCIÓN DE LOGIN
  Future<bool> login(String username, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'rememberMe': rememberMe,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _username = data['username'];
        _rol = data['rol'];
        _tienda = data['tienda'];

        // Guardamos los datos en la memoria del dispositivo
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!); // Guardamos con 'jwt_token'
        await prefs.setString('username', _username!);
        await prefs.setString('rol', _rol!);
        if (_tienda != null) await prefs.setString('tienda', _tienda!);

        _isLoading = false;
        notifyListeners();
        return true; // ¡Éxito!
      }
    } catch (e) {
      debugPrint("Error de conexión con Java: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false; // Falló el login
  }

  // 3. FUNCIÓN PARA CERRAR SESIÓN
  Future<void> logout() async {
    _token = null;
    _username = null;
    _rol = null;
    _tienda = null;

    // Borramos todo de la memoria del dispositivo
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}