import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class ReportesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _reporteMensual = [];
  List<Map<String, dynamic>> _reporteDiario = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get reporteMensual => _reporteMensual;
  List<Map<String, dynamic>> get reporteDiario => _reporteDiario;
  bool get isLoading => _isLoading;

  Future<void> fetchReportesGlobales() async {
    _isLoading = true;
    notifyListeners();
    try {
      final resMensual = await ApiService.get('/reportes/mensual');
      if (resMensual is List) {
        _reporteMensual = List<Map<String, dynamic>>.from(resMensual);
      }
      
      final resDiario = await ApiService.get('/reportes/diario');
      if (resDiario is List) {
        _reporteDiario = List<Map<String, dynamic>>.from(resDiario);
      }
    } catch (e) {
      debugPrint("Error fetching global reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
