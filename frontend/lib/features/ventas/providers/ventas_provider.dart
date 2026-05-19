import 'package:flutter/material.dart';
import '../models/nueva_venta_dto.dart';
import '../../../core/network/api_service.dart';

class VentasProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Enviar la nueva venta al servidor
  Future<bool> crearNuevaVenta(NuevaVentaDTO venta) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.post('/ventas/nueva', venta.toJson());
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}