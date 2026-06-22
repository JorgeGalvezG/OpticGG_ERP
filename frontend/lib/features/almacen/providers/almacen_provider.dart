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
      final response = await ApiService.get('/categorias');
      if (response != null && response is List) {
        _categorias = response.map((item) => CategoriaProducto.fromJson(item as Map<String, dynamic>)).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando categorias: $e");
    }
  }

  Future<void> fetchProductos(String tienda) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final String url = (tienda == 'ALL') ? '/almacen' : '/almacen/tienda/$tienda';
      final response = await ApiService.get(url);
      if (response != null && response is List) {
        _productos = response.map((item) => Almacen.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error cargando productos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Almacen?> buscarPorCodigo(String codigo) async {
    try {
      final response = await ApiService.get('/almacen/codigo/$codigo');
      if (response != null) {
        return Almacen.fromJson(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint("Error buscando por codigo: $e");
      return null;
    }
  }

  Future<bool> guardarProducto(Map<String, dynamic> data) async {
    try {
      await ApiService.post('/almacen', data);
      return true;
    } catch (e) {
      debugPrint("Error guardando producto: $e");
      return false;
    }
  }

  Future<bool> actualizarProducto(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.put('/almacen/$id', data);
      return true;
    } catch (e) {
      debugPrint("Error actualizando producto: $e");
      return false;
    }
  }

  // --- METODOS PARA CATEGORIAS ---
  Future<bool> guardarCategoria(Map<String, dynamic> data) async {
    try {
      await ApiService.post('/categorias', data);
      await fetchCategorias();
      return true;
    } catch (e) {
      debugPrint("Error guardando categoria: $e");
      return false;
    }
  }

  Future<bool> actualizarCategoria(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.put('/categorias/$id', data);
      await fetchCategorias();
      return true;
    } catch (e) {
      debugPrint("Error actualizando categoria: $e");
      return false;
    }
  }

  Future<bool> eliminarCategoria(int id) async {
    try {
      await ApiService.delete('/categorias/$id');
      await fetchCategorias();
      return true;
    } catch (e) {
      debugPrint("Error eliminando categoria: $e");
      return false;
    }
  }
}
