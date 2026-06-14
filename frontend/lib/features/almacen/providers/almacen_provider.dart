import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../models/almacen_model.dart';

import '../models/categoria_model.dart';

class AlmacenProvider with ChangeNotifier {
  List<Almacen> _productos = [];
  List<CategoriaProducto> _categorias = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Almacen> get productos => _productos;
  List<CategoriaProducto> get categorias => _categorias;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchCategorias() async {
    try {
      final response = await ApiService.get('/categorias'); // Asumiendo este endpoint
      _categorias = (response as List).map((item) => CategoriaProducto.fromJson(item)).toList();
      notifyListeners();
    } catch (e) {
      print("Error cargando categorías: $e");
    }
  }

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

  Future<bool> actualizarProducto(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.put('/almacen/$id', data);
      return true;
    } catch (e) {
      return false;
    }
  }
}