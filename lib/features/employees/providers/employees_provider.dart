import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/models/employee_model.dart';

class EmployeesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RestauAuthProvider _authProvider;
  StreamSubscription<QuerySnapshot>? _employeesSubscription;

  List<EmployeeModel> _employees = [];
  bool _isLoading = false;
  String? _error;
  bool _isStreamActive = false;

  EmployeesProvider(this._authProvider);

  void updateAuthProvider(RestauAuthProvider newAuthProvider) {
    _authProvider = newAuthProvider;
    // Reiniciar stream con nueva información de autenticación automáticamente
    if (_authProvider.companyId != null && _authProvider.companyId!.isNotEmpty) {
      startEmployeesStream();
    }
  }

  // 🚀 NUEVO: Auto-inicializar stream cuando hay companyId
  void autoStartStreamIfReady() {
    final companyId = _authProvider.companyId;
    if (companyId != null && companyId.isNotEmpty && !_isStreamActive) {
      debugPrint('🔥 AUTO-START: Iniciando stream automáticamente para: $companyId');
      startEmployeesStream();
    }
  }

  @override
  void dispose() {
    _employeesSubscription?.cancel();
    super.dispose();
  }
  // Getters
  List<EmployeeModel> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isStreamActive => _isStreamActive;
  int get totalEmployees => _employees.length;
  int get activeEmployees => _employees.where((e) => e.isActive).length;
  int get newEmployees {
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    return _employees.where((e) => e.joinDate.isAfter(oneMonthAgo)).length;
  }
  // 🚀 NUEVO: Forzar actualización completa del stream
  Future<void> forceRefreshEmployees() async {
    final companyId = _authProvider.companyId;
    if (companyId == null || companyId.isEmpty) {
      debugPrint('❌ forceRefreshEmployees: No hay companyId');
      return;
    }

    try {
      debugPrint('🔄 forceRefreshEmployees: Forzando actualización completa...');
      
      // 1. Forzar migración completa
      await _migrateFromUsersCollection(companyId);
      
      // 2. Reiniciar el stream interno si existe
      if (_employeesSubscription != null) {
        await _employeesSubscription!.cancel();
        _isStreamActive = false;
        await startEmployeesStream();
      }
      
      debugPrint('✅ forceRefreshEmployees: Actualización completa finalizada');
    } catch (e) {
      debugPrint('❌ forceRefreshEmployees ERROR: $e');
    }
  }

  String? getCompanyCode() => _authProvider.companyData?['code'];

  // 🔥 NUEVO: Stream directo para UI con migración automática integrada
  Stream<List<EmployeeModel>> get employeesStream {
    final companyId = _authProvider.companyId;
    
    if (companyId == null || companyId.isEmpty) {
      debugPrint('❌ employeesStream: No hay companyId');
      return Stream.value([]);
    }

    debugPrint('🚀 employeesStream: Iniciando stream para companyId: $companyId');
    
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('employees')
        .snapshots()
        .asyncMap((snapshot) async {
      try {
        debugPrint('📡 employeesStream: Recibido snapshot con ${snapshot.docs.length} empleados');
        
        // Si no hay empleados, intentar migrar automáticamente
        if (snapshot.docs.isEmpty) {
          debugPrint('🔄 employeesStream: No hay empleados, iniciando auto-migración...');
          await _migrateFromUsersCollection(companyId);
          
          // Volver a consultar después de la migración
          final newSnapshot = await _firestore
              .collection('companies')
              .doc(companyId)
              .collection('employees')
              .get();
          
          final employees = newSnapshot.docs
              .map((doc) => EmployeeModel.fromFirestore(doc))
              .toList();
          
          debugPrint('✅ employeesStream: Después de migración: ${employees.length} empleados');
          return employees;
        }
        
        // Convertir documentos a empleados
        final employees = snapshot.docs
            .map((doc) => EmployeeModel.fromFirestore(doc))
            .toList();
        
        debugPrint('✅ employeesStream: Devolviendo ${employees.length} empleados');
        return employees;
      } catch (e) {
        debugPrint('❌ employeesStream ERROR: $e');
        return <EmployeeModel>[];
      }
    });
  }

  // 🔥 NUEVO: Stream en tiempo real para empleados
  Future<void> startEmployeesStream() async {
    final companyId = _authProvider.companyId;
    
    if (companyId == null || companyId.isEmpty) {
      _setError('Usuario no tiene empresa asignada');
      return;
    }

    // Cancelar stream anterior si existe
    await _employeesSubscription?.cancel();
    
    debugPrint('🔄 STREAM: Iniciando stream de empleados para: $companyId');
    
    try {
      _setLoading(true);
      _setError(null);
      
      // Primero intentar migrar si es necesario
      await _ensureEmployeesCollection(companyId);
      
      // Configurar stream en tiempo real
      _employeesSubscription = _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .orderBy('joinDate', descending: true)
          .snapshots()
          .listen(
        (snapshot) async {
          debugPrint('📨 STREAM: Recibidos ${snapshot.docs.length} empleados');
          
          try {
            _employees = snapshot.docs
                .map((doc) => EmployeeModel.fromFirestore(doc))
                .toList();
            
            // Cargar conteos de pedidos para cada empleado
            await _loadOrderCounts(companyId);
            
            _setLoading(false);
            _isStreamActive = true;
            notifyListeners();
            
            debugPrint('✅ STREAM: Empleados actualizados - Total: ${_employees.length}');
          } catch (e) {
            debugPrint('❌ STREAM ERROR al procesar datos: $e');
            _setError('Error al procesar empleados: $e');
            _setLoading(false);
          }
        },
        onError: (error) {
          debugPrint('❌ STREAM ERROR: $error');
          _setError('Error en conexión: $error');
          _setLoading(false);
        },
      );
      
    } catch (e) {
      debugPrint('❌ ERROR iniciando stream: $e');
      _setError('Error al conectar con empleados: $e');
      _setLoading(false);
    }
  }

  // 🔄 MEJORADO: Asegurar que la colección de empleados existe
  Future<void> _ensureEmployeesCollection(String companyId) async {
    try {
      // Verificar si ya existe la subcolección employees
      final employeesQuery = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .limit(1)
          .get();
      
      if (employeesQuery.docs.isEmpty) {
        debugPrint('🔄 MIGRACIÓN: No hay empleados en subcolección, buscando en users...');
        await _migrateFromUsersCollection(companyId);
      } else {
        debugPrint('✅ COLECCIÓN: Empleados ya existen en subcolección');
      }
    } catch (e) {
      debugPrint('❌ ERROR en _ensureEmployeesCollection: $e');
      // No lanzar error, continuar con colección vacía
    }
  }

  // 🔄 MEJORADO: Migración desde users a employees MAS ROBUSTA
  Future<void> _migrateFromUsersCollection(String companyId) async {
    try {
      debugPrint('🔄 MIGRACIÓN: Iniciando migración para companyId: $companyId');
      
      // 1. Obtener TODOS los usuarios de la empresa
      final usersSnapshot = await _firestore
          .collection('users')
          .where('companyId', isEqualTo: companyId)
          .get();
      
      debugPrint('🔄 MIGRACIÓN: Encontrados ${usersSnapshot.docs.length} usuarios');
      
      if (usersSnapshot.docs.isEmpty) {
        debugPrint('🔄 MIGRACIÓN: No hay usuarios para migrar');
        return;
      }
      
      // 2. Obtener empleados ya migrados para evitar duplicados
      final existingEmployeesSnapshot = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .get();
      
      final existingEmployeeIds = existingEmployeesSnapshot.docs
          .map((doc) => doc.id)
          .toSet();
      
      debugPrint('🔄 MIGRACIÓN: Ya existen ${existingEmployeeIds.length} empleados migrados');
      
      // 3. Filtrar usuarios que AUN NO han sido migrados
      final usersToMigrate = usersSnapshot.docs
          .where((userDoc) => !existingEmployeeIds.contains(userDoc.id))
          .toList();
      
      debugPrint('🔄 MIGRACIÓN: ${usersToMigrate.length} usuarios necesitan migración');
      
      if (usersToMigrate.isEmpty) {
        debugPrint('🔄 MIGRACIÓN: Todos los usuarios ya están migrados');
        return;
      }
      
      // 4. Migrar usuarios faltantes usando batch
      final batch = _firestore.batch();
      
      for (final userDoc in usersToMigrate) {
        try {
          final userData = userDoc.data();
          
          // Crear documento de empleado en la subcolección
          final employeeRef = _firestore
              .collection('companies')
              .doc(companyId)
              .collection('employees')
              .doc(userDoc.id);
          
          final employeeData = {
            'name': userData['name'] ?? 'Usuario sin nombre',
            'email': userData['email'] ?? '',
            'role': userData['role'] ?? 'employee',
            'companyId': companyId,
            'isActive': userData['isActive'] ?? true,
            'joinDate': userData['joinDate'] ?? userData['createdAt'] ?? Timestamp.now(),
            'position': userData['position'],
            'ordersCount': 0,
            'migratedAt': Timestamp.now(),
            'migratedFrom': 'users_collection',
          };
          
          batch.set(employeeRef, employeeData);
          debugPrint('✅ MIGRACIÓN: Preparando ${userData['name']} (${userDoc.id})');
        } catch (e) {
          debugPrint('❌ MIGRACIÓN ERROR con usuario ${userDoc.id}: $e');
        }
      }
      
      // 5. Ejecutar migración
      await batch.commit();
      debugPrint('✅ MIGRACIÓN: Completada - ${usersToMigrate.length} nuevos empleados migrados');
      
    } catch (e) {
      debugPrint('❌ MIGRACIÓN ERROR: $e');
      // No lanzar error para no bloquear la aplicación
    }
  }

  // 🗑️ DEPRECIADO: Usar employeesStream en su lugar
  @Deprecated('Usar employeesStream para sincronización en tiempo real')
  Future<void> loadEmployees() async {
    debugPrint('⚠️ DEPRECIADO: loadEmployees() - Usar employeesStream');
    // Iniciar stream si no está activo
    autoStartStreamIfReady();
  }

  // LÓGICA COMPLETA DE CARGA Y MIGRACIÓN
  Future<void> _loadEmployeesFromCompany(String companyId) async {
    try {
      var querySnapshot = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .orderBy('joinDate', descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('Found ${querySnapshot.docs.length} employees in companies/$companyId/employees');
        _employees = querySnapshot.docs.map((doc) => EmployeeModel.fromFirestore(doc)).toList();
      } else {
        debugPrint('No employees found in subcollection, trying to load from users and migrate...');
        await _loadAndMigrateFromUsers(companyId);
      }
      await _loadOrderCounts(companyId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error in _loadEmployeesFromCompany: $e');
      throw Exception('Error cargando empleados: $e');
    }
  }

  Future<void> _loadAndMigrateFromUsers(String companyId) async {
    try {
      final usersSnapshot = await _firestore.collection('users').where('companyId', isEqualTo: companyId).get();
      if (usersSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        _employees = [];
        for (final userDoc in usersSnapshot.docs) {
          final userData = userDoc.data();
          final employee = EmployeeModel(
            uid: userDoc.id,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            role: userData['role'] ?? 'employee',
            companyId: companyId,
            isActive: userData['isActive'] ?? true,
            joinDate: (userData['joinDate'] as Timestamp?)?.toDate() ?? (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
          _employees.add(employee);
          final employeeRef = _firestore.collection('companies').doc(companyId).collection('employees').doc(userDoc.id);
          batch.set(employeeRef, employee.toFirestore());
        }
        await batch.commit();
      } else {
        _employees = [];
      }
    } catch (e) {
      debugPrint('Error in _loadAndMigrateFromUsers: $e');
      // SOLUCIÓN: En lugar de crear datos demo, dejamos la lista vacía.
      _employees = [];
    }
  }


  Future<void> _loadOrderCounts(String companyId) async {
    for (int i = 0; i < _employees.length; i++) {
      try {
        final ordersQuery = await _firestore.collection('companies').doc(companyId).collection('orders').where('employeeId', isEqualTo: _employees[i].uid).get();
        _employees[i] = _employees[i].copyWith(ordersCount: ordersQuery.docs.length);
      } catch (e) {
        debugPrint('Error loading order count for employee ${_employees[i].uid}: $e');
      }
    }
  }

  Future<void> toggleEmployeeStatus(String employeeId) async {
    final companyId = _authProvider.companyId;
    if (companyId == null) return;
    try {
      _setLoading(true);
      final employee = _employees.firstWhere((e) => e.uid == employeeId);
      final newStatus = !employee.isActive;
      await _firestore.collection('companies').doc(companyId).collection('employees').doc(employeeId).update({'isActive': newStatus});
      try {
        await _firestore.collection('users').doc(employeeId).update({'isActive': newStatus});
      } catch (e) {
        debugPrint('Could not update user status: $e');
      }
      final index = _employees.indexWhere((e) => e.uid == employeeId);
      if (index != -1) {
        _employees[index] = _employees[index].copyWith(isActive: newStatus);
        notifyListeners();
      }
    } catch (e) {
      _setError('Error al cambiar estado del empleado: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 🔧 Método para actualizar empleado completo
  Future<void> updateEmployee(
    String employeeId,
    String name,
    String email,
    String position,
    String role,
    bool isActive,
  ) async {
    final companyId = _authProvider.companyId;
    if (companyId == null) {
      throw Exception('No hay empresa válida');
    }

    try {
      _setLoading(true);
      _setError(null);

      // Datos a actualizar
      final updateData = {
        'name': name,
        'email': email,
        'position': position,
        'role': role,
        'isActive': isActive,
        'updatedAt': Timestamp.now(),
      };

      // Actualizar en Firestore (colección employees)
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .doc(employeeId)
          .update(updateData);

      // Intentar actualizar también en la colección users (si existe)
      try {
        await _firestore
            .collection('users')
            .doc(employeeId)
            .update(updateData);
      } catch (e) {
        debugPrint('No se pudo actualizar en users: $e');
      }

      // Actualizar en la lista local
      final index = _employees.indexWhere((e) => e.uid == employeeId);
      if (index != -1) {
        _employees[index] = _employees[index].copyWith(
          name: name,
          email: email,
          position: position,
          role: role,
          isActive: isActive,
        );
        notifyListeners();
      }

      debugPrint('Empleado $employeeId actualizado correctamente');
    } catch (e) {
      debugPrint('Error al actualizar empleado: $e');
      _setError('Error al actualizar empleado: $e');
      throw Exception('Error al actualizar empleado: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}