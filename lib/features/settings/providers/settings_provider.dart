// === MEJORAS PARA SETTINGS_PROVIDER.dart ===

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsProvider extends ChangeNotifier {
  // Estado de configuraciones de notificaciones
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _orderNotifications = true;
  bool _employeeNotifications = true;

  // Estado de configuraciones de empresa
  Map<String, dynamic> _companySettings = {};

  // Estado de carga
  bool _isLoading = false;
  String? _error;

  // Estadísticas de empresa
  Map<String, dynamic> _companyStats = {};

  // Getters
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get orderNotifications => _orderNotifications;
  bool get employeeNotifications => _employeeNotifications;
  Map<String, dynamic> get companySettings => _companySettings;
  Map<String, dynamic> get companyStats => _companyStats;
  bool get isLoading => _isLoading;
  String? get error => _error;



  // Cargar configuraciones al iniciar
  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadNotificationSettings(),
        _loadCompanySettings(),
        _loadCompanyStats(),
      ]);
    } catch (e) {
      _error = 'Error cargando configuraciones: $e';
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔔 CONFIGURACIONES DE NOTIFICACIONES MEJORADAS

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _orderNotifications = prefs.getBool('order_notifications') ?? true;
      _employeeNotifications = prefs.getBool('employee_notifications') ?? true;
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> updateNotificationSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);

      switch (key) {
        case 'push_notifications':
          _pushNotifications = value;
          break;
        case 'email_notifications':
          _emailNotifications = value;
          break;
        case 'order_notifications':
          _orderNotifications = value;
          break;
        case 'employee_notifications':
          _employeeNotifications = value;
          break;
      }

      notifyListeners();

      // Sincronizar con Firebase si es necesario
      await _syncNotificationSettingsToFirebase();
    } catch (e) {
      _error = 'Error updating notification setting: $e';
      debugPrint('Error updating notification setting: $e');
    }
  }

  Future<void> _syncNotificationSettingsToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'notificationSettings': {
            'push': _pushNotifications,
            'email': _emailNotifications,
            'orders': _orderNotifications,
            'employees': _employeeNotifications,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error syncing notification settings: $e');
    }
  }

  // 🏢 CONFIGURACIONES DE EMPRESA MEJORADAS

  Future<void> _loadCompanySettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Obtener datos del usuario para conseguir el companyId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final companyId = userData['companyId'];

        if (companyId != null) {
          final companyDoc = await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyId)
              .get();

          if (companyDoc.exists) {
            final companyData = companyDoc.data()!;
            _companySettings = companyData['settings'] ?? {};

            // Asegurar configuraciones por defecto
            _companySettings.putIfAbsent('currency', () => 'EUR');
            _companySettings.putIfAbsent('timezone', () => 'Europe/Madrid');
            _companySettings.putIfAbsent('language', () => 'es');
            _companySettings.putIfAbsent('orderLimits', () => {
              'enabled': true,
              'maxOrderAmount': 500.0,
              'monthlyLimit': 2000.0,
            });
            _companySettings.putIfAbsent('workingHours', () => {
              'enabled': false,
              'start': '09:00',
              'end': '18:00',
            });
            _companySettings.putIfAbsent('deliverySettings', () => {
              'defaultDeliveryDays': ['monday', 'wednesday', 'friday'],
              'defaultDeliveryTime': '10:00',
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading company settings: $e');
      _error = 'Error cargando configuraciones de empresa: $e';
    }
  }

  Future<void> updateCompanySettings(String companyId, Map<String, dynamic> newSettings) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .update({
        'settings': newSettings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _companySettings = newSettings;
      _error = null;
    } catch (e) {
      _error = 'Error actualizando configuraciones: $e';
      debugPrint('Error updating company settings: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 📊 ESTADÍSTICAS DE EMPRESA

  Future<void> _loadCompanyStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final companyId = userData['companyId'];

        if (companyId != null) {
          // Obtener estadísticas en paralelo
          final results = await Future.wait([
            _getEmployeeCount(companyId),
            _getMonthlyOrderCount(companyId),
            _getMonthlySpending(companyId),
            _getMostActiveEmployee(companyId),
            _getSupplierCount(companyId),
            _getProductCount(companyId),
          ]);

          _companyStats = {
            'activeEmployees': results[0],
            'monthlyOrders': results[1],
            'monthlySpending': results[2],
            'mostActiveEmployee': results[3],
            'totalSuppliers': results[4],
            'totalProducts': results[5],
            'lastUpdated': DateTime.now(),
          };
        }
      }
    } catch (e) {
      debugPrint('Error loading company stats: $e');
      _error = 'Error cargando estadísticas: $e';
    }
  }

  Future<int> _getEmployeeCount(String companyId) async {
    try {
      final employeesQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .where('isActive', isEqualTo: true)
          .get();

      return employeesQuery.docs.length;
    } catch (e) {
      debugPrint('Error getting employee count: $e');
      return 0;
    }
  }

  Future<int> _getMonthlyOrderCount(String companyId) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final ordersQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: firstDayOfMonth)
          .get();

      return ordersQuery.docs.length;
    } catch (e) {
      debugPrint('Error getting monthly order count: $e');
      return 0;
    }
  }

  Future<double> _getMonthlySpending(String companyId) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final ordersQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('status', isEqualTo: 'sent')
          .get();

      double totalSpending = 0.0;
      for (final doc in ordersQuery.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        final totalAmount = orderData['totalAmount'] as num? ?? 0;
        totalSpending += totalAmount.toDouble();
      }

      return totalSpending;
    } catch (e) {
      debugPrint('Error getting monthly spending: $e');
      return 0.0;
    }
  }

  Future<String> _getMostActiveEmployee(String companyId) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final ordersQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: firstDayOfMonth)
          .get();

      Map<String, int> employeeOrderCounts = {};

      for (final doc in ordersQuery.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        final employeeName = orderData['employeeName'] as String? ?? 'Desconocido';
        employeeOrderCounts[employeeName] = (employeeOrderCounts[employeeName] ?? 0) + 1;
      }

      if (employeeOrderCounts.isEmpty) return 'N/A';

      final mostActive = employeeOrderCounts.entries.reduce(
              (a, b) => a.value > b.value ? a : b
      );

      return '${mostActive.key} (${mostActive.value} pedidos)';
    } catch (e) {
      debugPrint('Error getting most active employee: $e');
      return 'N/A';
    }
  }

  Future<int> _getSupplierCount(String companyId) async {
    try {
      final suppliersQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .where('isActive', isEqualTo: true)
          .get();

      return suppliersQuery.docs.length;
    } catch (e) {
      debugPrint('Error getting supplier count: $e');
      return 0;
    }
  }

  Future<int> _getProductCount(String companyId) async {
    try {
      final productsQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      return productsQuery.docs.length;
    } catch (e) {
      debugPrint('Error getting product count: $e');
      return 0;
    }
  }

  // 👥 CONFIGURACIONES DE EMPLEADOS MEJORADAS

  Future<void> updateEmployeeLimits(String companyId, Map<String, dynamic> limits) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedSettings = Map<String, dynamic>.from(_companySettings);
      updatedSettings['orderLimits'] = limits;

      await updateCompanySettings(companyId, updatedSettings);

      // Aplicar límites a empleados existentes (opcional)
      if (limits['applyToExisting'] == true) {
        await _applyLimitsToExistingEmployees(companyId, limits);
      }
    } catch (e) {
      _error = 'Error actualizando límites de empleados: $e';
      debugPrint('Error updating employee limits: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applyLimitsToExistingEmployees(String companyId, Map<String, dynamic> limits) async {
    try {
      final employeesQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .where('role', isEqualTo: 'employee')
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in employeesQuery.docs) {
        final employeeRef = doc.reference;
        batch.update(employeeRef, {
          'permissions.maxOrderAmount': limits['maxOrderAmount'],
          'permissions.monthlyLimit': limits['monthlyLimit'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error applying limits to existing employees: $e');
    }
  }

  // 🔐 CONFIGURACIONES DE SEGURIDAD

  Future<void> updateSecuritySettings(String companyId, Map<String, dynamic> securitySettings) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedSettings = Map<String, dynamic>.from(_companySettings);
      updatedSettings['security'] = securitySettings;

      await updateCompanySettings(companyId, updatedSettings);
    } catch (e) {
      _error = 'Error actualizando configuraciones de seguridad: $e';
      debugPrint('Error updating security settings: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔄 BACKUP Y RESTAURACIÓN

  Future<Map<String, dynamic>> createBackupData(String companyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final backupData = <String, dynamic>{};

      // Información de la empresa
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();

      if (companyDoc.exists) {
        backupData['company'] = companyDoc.data();
      }

      // Empleados
      final employeesQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .get();

      backupData['employees'] = employeesQuery.docs.map((doc) => {
        'id': doc.id,
        'data': doc.data(),
      }).toList();

      // Proveedores
      final suppliersQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .get();

      backupData['suppliers'] = suppliersQuery.docs.map((doc) => {
        'id': doc.id,
        'data': doc.data(),
      }).toList();

      // Productos
      final productsQuery = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('products')
          .get();

      backupData['products'] = productsQuery.docs.map((doc) => {
        'id': doc.id,
        'data': doc.data(),
      }).toList();

      // Metadatos del backup
      backupData['backup_metadata'] = {
        'created_at': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'company_id': companyId,
      };

      return backupData;
    } catch (e) {
      _error = 'Error creando backup: $e';
      debugPrint('Error creating backup: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔄 RESET DE CONFIGURACIONES

  Future<void> resetToDefaults() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      // Reset notificaciones
      _pushNotifications = true;
      _emailNotifications = true;
      _orderNotifications = true;
      _employeeNotifications = true;

      await prefs.setBool('push_notifications', true);
      await prefs.setBool('email_notifications', true);
      await prefs.setBool('order_notifications', true);
      await prefs.setBool('employee_notifications', true);

      // Reset configuraciones de empresa a valores por defecto
      _companySettings = {
        'currency': 'EUR',
        'timezone': 'Europe/Madrid',
        'language': 'es',
        'orderLimits': {
          'enabled': true,
          'maxOrderAmount': 500.0,
          'monthlyLimit': 2000.0,
        },
        'workingHours': {
          'enabled': false,
          'start': '09:00',
          'end': '18:00',
        },
        'deliverySettings': {
          'defaultDeliveryDays': ['monday', 'wednesday', 'friday'],
          'defaultDeliveryTime': '10:00',
        },
      };

      _error = null;
    } catch (e) {
      _error = 'Error reseteando configuraciones: $e';
      debugPrint('Error resetting to defaults: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 📊 MÉTODOS DE ESTADÍSTICAS

  Future<void> refreshStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final companyId = userData['companyId'];

        if (companyId != null) {
          await _loadCompanyStats();
        }
      }
    } catch (e) {
      debugPrint('Error refreshing stats: $e');
    }
  }

  // 📱 UTILIDADES

  String get notificationSummary {
    final enabledCount = [
      _pushNotifications,
      _emailNotifications,
      _orderNotifications,
      _employeeNotifications,
    ].where((enabled) => enabled).length;

    return '$enabledCount de 4 notificaciones activas';
  }

  bool get hasUnsavedChanges {
    // Implementar lógica para detectar cambios no guardados
    return false;
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Obtener estadística específica
  T? getStat<T>(String key) {
    try {
      return _companyStats[key] as T?;
    } catch (e) {
      debugPrint('Error getting stat $key: $e');
      return null;
    }
  }

  // Métodos específicos para actualizar notificaciones (requeridos por notifications_section.dart)
  void updatePushNotifications(bool value) {
    updateNotificationSetting('push_notifications', value);
  }

  void updateEmailNotifications(bool value) {
    updateNotificationSetting('email_notifications', value);
  }

  void updateOrderNotifications(bool value) {
    updateNotificationSetting('order_notifications', value);
  }

  void updateEmployeeNotifications(bool value) {
    updateNotificationSetting('employee_notifications', value);
  }
}