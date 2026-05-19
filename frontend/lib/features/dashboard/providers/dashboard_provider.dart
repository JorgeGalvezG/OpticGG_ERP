import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../models/dashboard_resumen.dart';

class DashboardProvider with ChangeNotifier {
  DashboardResumen? _resumen;
  bool _isLoading = false;
  String _errorMessage = '';

  DashboardResumen? get resumen => _resumen;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchResumen(String tienda) async {
    _isLoading = true;
    _errorMessage = '';
    // notifyListeners(); // Opcional si quieres que se vea el loading inmediato

    try {
      // Llamamos al endpoint que creamos en Spring Boot
      final response = await ApiService.get('/dashboard/resumen/$tienda');
      _resumen = DashboardResumen.fromJson(response);
    } catch (e) {
      _errorMessage = e.toString();
      _resumen = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}