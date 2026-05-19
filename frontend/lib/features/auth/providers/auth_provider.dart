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
  bool _isLoading = false;

  // Getters (para que la interfaz visual pueda leer estos datos)
  // Como _token ya no es nulo cuando inicias sesión, isAuthenticated se vuelve "true" automáticamente
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get username => _username;
  String? get rol => _rol;
  String? get tienda => _tienda;

  // 1. REVISAR SI YA HAY SESIÓN GUARDADA
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // OJO: Buscamos exactamente con la misma llave que usamos al guardar ('jwt_token')
    final token = prefs.getString('jwt_token');

    if (token != null && token.isNotEmpty) {
      _token = token;
      _username = prefs.getString('username');
      _rol = prefs.getString('rol');
      _tienda = prefs.getString('tienda');

      notifyListeners();
      return true; // Sí encontró la sesión
    }
    return false; // No hay sesión, debe ir al login
  }

  // 2. FUNCIÓN DE LOGIN
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
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