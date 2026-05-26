import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../../../core/network/api_service.dart';

class UsuariosProvider with ChangeNotifier {
  List<Usuario> _usuariosActivos = [];
  List<Usuario> _todosLosUsuarios = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters para que la vista lea los datos
  List<Usuario> get usuariosActivos => _usuariosActivos;
  List<Usuario> get todosLosUsuarios => _todosLosUsuarios;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // 1. Obtener la lista para el desplegable de Ventas
  Future<void> fetchActivosPorTienda(String tienda) async {
    _isLoading = true;
    notifyListeners(); // Avisa a la pantalla que muestre un circulito de carga

    try {
      // Llamamos al endpoint que armaste en Java
      final response = await ApiService.get('/usuarios/tienda/$tienda/activos');

      // Convertimos el JSON crudo en una lista de objetos Usuario
      _usuariosActivos = (response as List).map((i) => Usuario.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisa a la pantalla que ya tenemos los datos
    }
  }
  Future<void> fetchTodosLosUsuarios() async {
    _isLoading = true; notifyListeners();
    try {
      // Pedimos todos los usuarios a la ruta principal
      final response = await ApiService.get('/usuarios?page=0&size=100');
      // Spring Boot devuelve una clase "Page", por lo que la lista real viene dentro de "content"
      _todosLosUsuarios = (response['content'] as List).map((i) => Usuario.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  // 3. Crear un nuevo vendedor
  Future<bool> crearUsuario(Usuario nuevoUsuario) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mandamos el POST a Java
      await ApiService.post('/usuarios', nuevoUsuario.toJson());

      // Si se guardó bien, volvemos a pedir la lista actualizada
      await fetchTodosLosUsuarios();
      return true; // Éxito
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Falló
    }
  }

  Future<bool> cambiarEstadoActivo(int userId) async {
    try {
      await ApiService.patch('/usuarios/$userId/estado', {});
      await fetchTodosLosUsuarios();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> buscarUsuarios(String termino) async {
    if (termino.isEmpty) {
      return fetchTodosLosUsuarios(); // Si borra el texto, trae a todos de vuelta
    }

    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.get('/usuarios/buscar?termino=$termino&page=0&size=100');
      _todosLosUsuarios = (response['content'] as List).map((i) => Usuario.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
}