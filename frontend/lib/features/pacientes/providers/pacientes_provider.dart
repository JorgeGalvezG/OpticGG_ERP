import 'package:flutter/material.dart';
import '../models/paciente_model.dart';
import '../models/paciente_reactivar_model.dart';
import '../models/paciente_con_medida_dto.dart';
import '../models/historial_paciente_dto.dart';
import '../../../core/network/api_service.dart';

class PacientesProvider with ChangeNotifier {
  List<Paciente> _pacientes = [];
  List<Paciente> _pacientesVip = [];
  List<PacienteReactivar> _pacientesPorReactivar = [];
  HistorialPacienteDTO? _historialResumen;

  bool _isLoading = false;
  String _errorMessage = '';

  List<Paciente> get pacientes => _pacientes;
  List<Paciente> get pacientesVip => _pacientesVip;
  List<PacienteReactivar> get pacientesPorReactivar => _pacientesPorReactivar;
  HistorialPacienteDTO? get historialResumen => _historialResumen;

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

  Future<HistorialPacienteDTO?> fetchHistorialResumen(int pacienteId) async {
    try {
      final response = await ApiService.get('/pacientes/$pacienteId/historial');
      _historialResumen = HistorialPacienteDTO.fromJson(response);
      return _historialResumen;
    } catch (e) {
      print("❌ Error al traer resumen: $e");
      return null;
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
  Future<Paciente?> crearPaciente(PacienteConMedidaDTO nuevo) async {
    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.post('/pacientes', nuevo.toJson());
      await fetchPacientes(nuevo.tienda); // Recarga la lista para que aparezca al instante
      return Paciente.fromJson(response);
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false; notifyListeners();
      return null;
    }
  }
  // 5. Actualizar Paciente Existente
  Future<bool> actualizarPaciente(PacienteConMedidaDTO paciente) async {
    _isLoading = true; notifyListeners();
    try {
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

  Future<void> fetchPacientesPorReactivar(String tienda) async {
    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.get('/pacientes/tienda/$tienda/reactivar');
      _pacientesPorReactivar = (response as List).map((i) => PacienteReactivar.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  void filtrarPorFecha(DateTimeRange rango) {
    // Nota: Para un filtrado real por fecha de registro, el modelo Paciente debería traer ese dato.
    // Por ahora, si no lo tiene, este método evita el error en rojo y permite extender la lógica.
    // Si tienes el campo fechaRegistro en el modelo, descomenta la lógica de abajo:
    /*
    _pacientes = _pacientes.where((p) {
      if (p.fechaRegistro == null) return false;
      final fecha = DateTime.parse(p.fechaRegistro!);
      return fecha.isAfter(rango.start) && fecha.isBefore(rango.end.add(Duration(days: 1)));
    }).toList();
    */
    notifyListeners();
  }
}