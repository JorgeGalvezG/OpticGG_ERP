import 'package:flutter/material.dart';
import '../models/paciente_model.dart';
import '../../../core/network/api_service.dart';

class PacientesProvider with ChangeNotifier {
  List<Paciente> _pacientes = [];
  List<Paciente> _pacientesVip = [];

  bool _isLoading = false;
  String _errorMessage = '';

  List<Paciente> get pacientes => _pacientes;
  List<Paciente> get pacientesVip => _pacientesVip;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  //  Obtener la lista de pacientes de la tienda
  Future<void> fetchPacientes(String tienda) async {
    _isLoading = true; notifyListeners();
    try {
      // Pedimos la página 0 con tamaño 50
      final response = await ApiService.get('/pacientes/tienda/$tienda?page=0&size=50');

      // La lista real viene dentro de 'content' en Spring Boot
      _pacientes = (response['content'] as List).map((i) => Paciente.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  //  Buscador Dinámico
  Future<void> buscarPacientes(String termino, String tienda) async {
    if (termino.isEmpty) {
      return fetchPacientes(tienda); // Si borra el texto, trae todos
    }

    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.get('/pacientes/buscar?tienda=$tienda&termino=$termino&page=0&size=50');
      _pacientes = (response['content'] as List).map((i) => Paciente.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  // 4. Crear Paciente Nuevo
  Future<bool> crearPaciente(Paciente nuevo) async {
    _isLoading = true; notifyListeners();
    try {
      await ApiService.post('/pacientes', nuevo.toJson());
      await fetchPacientes(nuevo.tienda); // Recarga la lista para que aparezca al instante
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false; notifyListeners();
      return false;
    }
  }
  // 5. Actualizar Paciente Existente
  Future<bool> actualizarPaciente(Paciente paciente) async {
    _isLoading = true; notifyListeners();
    try {
      // Usamos el ID del paciente en la URL (Ej: /pacientes/5)
      await ApiService.put('/pacientes/${paciente.id}', paciente.toJson());
      await fetchPacientes(paciente.tienda); // Recarga la lista
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false; notifyListeners();
      return false;
    }
  }
  Future<void> fetchPacientesVip(String tienda) async {
    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.get('/pacientes/tienda/$tienda/vip');
      _pacientesVip = (response as List).map((i) => Paciente.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
}