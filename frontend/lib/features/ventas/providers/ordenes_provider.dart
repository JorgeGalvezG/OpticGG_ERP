import 'package:flutter/material.dart';
import '../models/orden_trabajo_model.dart';
import '../../../core/network/api_service.dart';

class OrdenesProvider with ChangeNotifier {
  List<OrdenTrabajo> _ordenes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // ¡LA MAGIA DEL KANBAN ESTÁ AQUÍ! Filtramos la lista principal por estados
  List<OrdenTrabajo> get pendientes => _ordenes.where((o) => o.estado == 'PENDIENTE').toList();
  List<OrdenTrabajo> get enLaboratorio => _ordenes.where((o) => o.estado == 'LABORATORIO').toList();
  List<OrdenTrabajo> get listos => _ordenes.where((o) => o.estado == 'LISTO').toList();
  List<OrdenTrabajo> get entregados => _ordenes.where((o) => o.estado == 'ENTREGADO').toList();

  // Descargar todo el tablero de golpe
  Future<void> fetchOrdenesTablero(String tienda) async {
    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.get('/ordenes/tienda/$tienda/tablero');
      _ordenes = (response as List).map((i) => OrdenTrabajo.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
  //mover tarjeta de columna
  Future<bool> actualizarEstadoOrden(int ordenId, String nuevoEstado, String tienda) async {
    _isLoading = true; notifyListeners();
    try {
      await ApiService.put('/ordenes/$ordenId/estado', {'nuevoEstado': nuevoEstado});
      // Volvemos a descargar el tablero para que la tarjeta aparezca en su nueva columna
      await fetchOrdenesTablero(tienda);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false; notifyListeners();
      return false;
    }
  }
}