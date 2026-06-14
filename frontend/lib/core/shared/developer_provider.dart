import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class DeveloperProvider with ChangeNotifier {
  bool _isDevMode = false;
  Map<String, dynamic>? _auditReport;
  bool _isLoading = false;

  bool get isDevMode => _isDevMode;
  Map<String, dynamic>? get auditReport => _auditReport;
  bool get isLoading => _isLoading;

  void toggleDevMode() {
    _isDevMode = !_isDevMode;
    notifyListeners();
  }

  Future<void> fetchAuditReport() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/audit/report');
      _auditReport = response as Map<String, dynamic>;
    } catch (e) {
      print("Error fetching audit report: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
