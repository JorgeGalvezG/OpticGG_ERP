import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/models/config_tienda_model.dart';

class ConfigProvider extends ChangeNotifier {
  ConfigTienda? _config;
  bool _isLoading = false;

  ConfigTienda? get config => _config;
  bool get isLoading => _isLoading;

  Future<void> cargarConfig(String tiendaCod) async {
    print('🔍 ConfigProvider: Intentando cargar configuración para tienda: $tiendaCod');
    _isLoading = true;
    notifyListeners();

    try {
      print('🌐 ApiService: GET /api/config-tienda/$tiendaCod');
      final data = await ApiService.get('/api/config-tienda/$tiendaCod');
      
      if (data == null) {
        throw Exception('El servidor devolvió datos vacíos para la tienda $tiendaCod');
      }

      print('✅ ConfigProvider: JSON Recibido -> $data');
      _config = ConfigTienda.fromJson(data);
      print('✅ ConfigProvider: Configuración cargada -> ${_config?.nombreOptica}');
    } catch (e) {
      print('❌ ERROR en cargarConfig($tiendaCod): $e');
      
      // Fallback: Si falla la tienda del usuario, intentar cargar C1 por defecto para no romper la app
      if (tiendaCod != 'C1') {
        print('⚠️ Intentando fallback a tienda C1...');
        await cargarConfig('C1');
      } else {
        _config = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
