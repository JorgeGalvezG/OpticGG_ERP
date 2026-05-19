import 'package:flutter/material.dart';
import '../models/movimiento_caja_model.dart';
import '../models/nuevo_movimiento_dto.dart';
import '../../../core/network/api_service.dart';

class CajaProvider with ChangeNotifier {
  List<MovimientoCaja> _movimientos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<MovimientoCaja> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // 🧮 CÁLCULOS AUTOMÁTICOS PARA EL DASHBOARD
  double get totalIngresos {
    return _movimientos.where((m) => m.tipo == 'ENTRADA').fold(0.0, (sum, m) => sum + m.monto);
  }

  double get totalSalidas {
    return _movimientos.where((m) => m.tipo == 'SALIDA').fold(0.0, (sum, m) => sum + m.monto);
  }

  double get saldoActual => totalIngresos - totalSalidas;

  // 1. Obtener historial
  Future<void> fetchMovimientos(String tienda) async {
    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.get('/caja/tienda/$tienda');
      _movimientos = (response as List).map((i) => MovimientoCaja.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  // 2. Registrar movimiento manual (Gasto o Ingreso extra)
  Future<bool> registrarMovimiento(NuevoMovimientoDTO dto) async {
    _isLoading = true; notifyListeners();
    try {
      await ApiService.post('/caja/manual', dto.toJson());
      await fetchMovimientos(dto.tienda); // Recarga la lista y actualiza los saldos
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false; notifyListeners();
      return false;
    }
  }
}