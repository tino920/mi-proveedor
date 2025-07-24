import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_proveedor/core/auth/auth_provider.dart'; // Asegúrate de que la ruta sea correcta

/// 👑 PROVIDER PARA CONFIGURACIONES DE LA EMPRESA (SOLO ADMIN)
/// Maneja datos que se guardan en Firestore en el documento de la compañía.
class AdminSettingsProvider extends ChangeNotifier {
  final RestauAuthProvider _authProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ⚙️ ESTADO DE LAS CONFIGURACIONES
  double _maxOrderAmount = 500.0;
  double _monthlyLimitPerEmployee = 2000.0;
  bool _areLimitsEnabled = false;

  bool _isLoading = false;
  String? _error;

  // ✨ GETTERS
  double get maxOrderAmount => _maxOrderAmount;
  double get monthlyLimitPerEmployee => _monthlyLimitPerEmployee;
  bool get areLimitsEnabled => _areLimitsEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminSettingsProvider(this._authProvider) {
    // Si el usuario ya está logueado al crear el provider, cargamos los datos.
    if (_authProvider.companyId != null) {
      loadCompanySettings();
    }
  }

  // 🔄 Método para actualizar el authProvider (usado por ChangeNotifierProxyProvider)
  void updateAuthProvider(RestauAuthProvider newAuthProvider) {
    // Si el companyId cambia (ej. al hacer login), recargamos los datos.
    if (_authProvider.companyId != newAuthProvider.companyId) {
      loadCompanySettings();
    }
  }

  // ☁️ Cargar las configuraciones desde Firestore
  Future<void> loadCompanySettings() async {
    final companyId = _authProvider.companyId;
    if (companyId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('companies').doc(companyId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final settings = data['settings'] as Map<String, dynamic>? ?? {};

        _maxOrderAmount = (settings['maxOrderAmount'] as num?)?.toDouble() ?? 500.0;
        _monthlyLimitPerEmployee = (settings['monthlyLimitPerEmployee'] as num?)?.toDouble() ?? 2000.0;
        _areLimitsEnabled = settings['employeeOrderLimits'] as bool? ?? false;
        _error = null;
      }
    } catch (e) {
      _error = 'Error cargando las configuraciones de la empresa.';
      debugPrint('Error en AdminSettingsProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 💾 Actualizar los límites de los empleados en Firestore
  Future<bool> updateEmployeeLimits(double newMaxOrder, double newMonthlyLimit, bool areEnabled) async {
    final companyId = _authProvider.companyId;
    if (companyId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('companies').doc(companyId).update({
        'settings.maxOrderAmount': newMaxOrder,
        'settings.monthlyLimitPerEmployee': newMonthlyLimit,
        'settings.employeeOrderLimits': areEnabled,
      });
      _maxOrderAmount = newMaxOrder;
      _monthlyLimitPerEmployee = newMonthlyLimit;
      _areLimitsEnabled = areEnabled;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Error guardando los límites.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
