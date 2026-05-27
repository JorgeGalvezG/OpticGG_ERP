import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/models/config_tienda_model.dart';

class ConfigProvider extends ChangeNotifier {
  ConfigTienda? _config;
  bool _isLoading = false;

  ConfigTienda? get config => _config;
  bool get isLoading => _isLoading;

  Future<void> cargarConfig(String tiendaCod) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.get('/api/config-tienda/$tiendaCod');
      _config = ConfigTienda.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error cargando configuración de tienda: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
