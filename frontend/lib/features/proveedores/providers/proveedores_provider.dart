import 'package:flutter/material.dart';
import '../models/proveedor_model.dart';
import '../../../core/network/api_service.dart';

class ProveedoresProvider with ChangeNotifier {
  List<Proveedor> _proveedores = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Proveedor> get proveedores => _proveedores;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchProveedores(String tienda) async {
    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.get('/proveedores/tienda/$tienda');
      _proveedores = (response as List).map((i) => Proveedor.fromJson(i)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> registrarNuevaCompra(Map<String, dynamic> dto) async {
    _isLoading = true; notifyListeners();
    try {
      await ApiService.post('/compras', dto);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> crearProveedor(Proveedor proveedor) async {
    _isLoading = true; notifyListeners();
    try {
      await ApiService.post('/proveedores', proveedor.toJson());
      await fetchProveedores(proveedor.tienda);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false; notifyListeners();
      return false;
    }
  }
}