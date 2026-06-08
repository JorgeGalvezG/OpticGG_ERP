import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../models/almacen_model.dart';

class AlmacenProvider with ChangeNotifier {
  List<Almacen> _productos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Almacen> get productos => _productos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchProductos(String tienda) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/almacen/tienda/$tienda');
      _productos = (response as List).map((item) => Almacen.fromJson(item)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Almacen?> buscarPorCodigo(String codigo) async {
    try {
      final response = await ApiService.get('/almacen/codigo/$codigo');
      return Almacen.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> guardarProducto(Map<String, dynamic> data) async {
    try {
      await ApiService.post('/almacen', data);
      return true;
    } catch (e) {
      return false;
    }
  }
}