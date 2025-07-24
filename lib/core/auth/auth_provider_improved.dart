import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  UserModel? _currentUser;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _companyData;
  bool _isLoading = true;
  String? _lastError;
  
  User? get user => _user;
  UserModel? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get companyData => _companyData;
  bool get isLoading => _isLoading;
  String? get userRole => _userData?['role'];
  String? get companyId => _userData?['companyId'];
  String? get lastError => _lastError;
  
  AuthProvider() {
    _initWithTimeout();
  }
  
  Future<void> _initWithTimeout() async {
    try {
      // Timeout de 15 segundos para evitar carga infinita
      await Future.any([
        _init(),
        Future.delayed(const Duration(seconds: 15), () {
          throw TimeoutException('Firebase initialization timeout', const Duration(seconds: 15));
        }),
      ]);
    } catch (e) {
      _lastError = 'Error de inicialización: $e';
      print('Error en inicialización: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _init() async {
    try {
      // Verificar que Firebase esté disponible
      print('🔄 Inicializando AuthProvider...');
      
      // Timeout para authStateChanges
      final authState = await _auth.authStateChanges().first.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ Timeout en authStateChanges');
          return null;
        },
      );
      
      print('🔑 Estado inicial de auth: ${authState?.email ?? "No user"}');
      
      _auth.authStateChanges().listen((User? user) async {
        print('🔄 Auth state changed: ${user?.email ?? "No user"}');
        _user = user;
        _lastError = null; // Limpiar errores previos
        
        if (user != null) {
          try {
            await _loadUserData();
          } catch (e) {
            _lastError = 'Error cargando datos: $e';
            print('❌ Error cargando datos del usuario: $e');
          }
        } else {
          _currentUser = null;
          _userData = null;
          _companyData = null;
          print('🚪 Usuario deslogueado');
        }
        
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _lastError = 'Error en autenticación: $error';
        print('❌ Error en auth state changes: $error');
        _isLoading = false;
        notifyListeners();
      });
      
    } catch (e) {
      _lastError = 'Error fatal de inicialización: $e';
      print('💥 Error en _init: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadUserData() async {
    if (_user == null) return;
    
    try {
      print('📋 Cargando datos del usuario: ${_user!.uid}');
      
      // Cargar datos del usuario con timeout
      final userDoc = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      
      if (userDoc.exists) {
        _userData = userDoc.data();
        _currentUser = UserModel.fromMap(_user!.uid, _userData!);
        print('✅ Datos del usuario cargados: ${_userData?['role']}');
        
        // Cargar datos de la empresa si existe
        if (_userData?['companyId'] != null) {
          try {
            final companyDoc = await _firestore
                .collection('companies')
                .doc(_userData!['companyId'])
                .get()
                .timeout(const Duration(seconds: 10));
            
            if (companyDoc.exists) {
              _companyData = companyDoc.data();
              print('🏢 Datos de empresa cargados: ${_companyData?['name']}');
            } else {
              print('⚠️ Empresa no encontrada: ${_userData!['companyId']}');
            }
          } catch (e) {
            print('❌ Error cargando empresa: $e');
            // No es crítico, continuar sin datos de empresa
          }
        }
      } else {
        print('❌ Documento de usuario no existe');
        _lastError = 'Usuario no encontrado en base de datos';
      }
    } catch (e) {
      _lastError = 'Error cargando datos: $e';
      print('❌ Error cargando datos del usuario: $e');
    }
    
    notifyListeners();
  }
  
  // Registro de empresa (Admin)
  Future<Map<String, dynamic>> registerCompany({
    required String companyName,
    required String adminEmail,
    required String adminPassword,
    required String adminName,
  }) async {
    try {
      print('🏢 Registrando empresa: $companyName');
      
      // Crear usuario admin
      final credential = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      
      final userId = credential.user!.uid;
      print('👤 Usuario admin creado: $userId');
      
      // Generar código único de empresa
      final companyCode = _generateCompanyCode(companyName);
      print('🔑 Código de empresa generado: $companyCode');
      
      // Crear documento de empresa
      final companyRef = _firestore.collection('companies').doc();
      await companyRef.set({
        'name': companyName,
        'code': companyCode,
        'adminEmail': adminEmail,
        'adminId': userId,
        'members': [userId], // Lista de miembros para las reglas de seguridad
        'admins': [userId],  // Lista de admins para las reglas de seguridad
        'createdAt': FieldValue.serverTimestamp(),
        'settings': {
          'employeeOrderLimits': false,
          'maxOrderAmount': 500,
          'monthlyLimitPerEmployee': 2000,
        },
      });
      
      print('🏢 Documento de empresa creado: ${companyRef.id}');
      
      // Crear documento de usuario admin
      await _firestore.collection('users').doc(userId).set({
        'name': adminName,
        'email': adminEmail,
        'role': 'admin',
        'companyId': companyRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('👤 Documento de usuario admin creado');
      
      // Añadir admin a la colección de empleados
      await _firestore
          .collection('companies')
          .doc(companyRef.id)
          .collection('employees')
          .doc(userId)
          .set({
        'name': adminName,
        'email': adminEmail,
        'role': 'admin',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Empresa registrada exitosamente');
      
      return {
        'success': true,
        'companyCode': companyCode,
      };
    } catch (e) {
      print('❌ Error registrando empresa: $e');
      return {
        'success': false,
        'error': _parseError(e),
      };
    }
  }
  
  // Registro de empleado
  Future<Map<String, dynamic>> registerEmployee({
    required String companyCode,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('👨‍💼 Registrando empleado con código: $companyCode');
      
      // Buscar empresa por código
      final companiesQuery = await _firestore
          .collection('companies')
          .where('code', isEqualTo: companyCode)
          .limit(1)
          .get();
      
      if (companiesQuery.docs.isEmpty) {
        print('❌ Código de empresa no válido: $companyCode');
        return {
          'success': false,
          'error': 'Código de empresa no válido',
        };
      }
      
      final companyDoc = companiesQuery.docs.first;
      final companyId = companyDoc.id;
      final companyData = companyDoc.data();
      
      print('🏢 Empresa encontrada: ${companyData['name']}');
      
      // Crear usuario empleado
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final userId = credential.user!.uid;
      print('👤 Usuario empleado creado: $userId');
      
      // Actualizar lista de miembros de la empresa
      await _firestore.collection('companies').doc(companyId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
      
      // Crear documento de usuario empleado
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'role': 'employee',
        'companyId': companyId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Añadir empleado a la colección de la empresa
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .doc(userId)
          .set({
        'name': name,
        'email': email,
        'role': 'employee',
        'active': true,
        'monthlySpent': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Empleado registrado exitosamente');
      
      return {'success': true};
    } catch (e) {
      print('❌ Error registrando empleado: $e');
      return {
        'success': false,
        'error': _parseError(e),
      };
    }
  }
  
  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔑 Intentando login para: $email');
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ Login exitoso');
      return {'success': true};
    } catch (e) {
      print('❌ Error en login: $e');
      return {
        'success': false,
        'error': _parseError(e),
      };
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      print('🚪 Cerrando sesión...');
      await _auth.signOut();
      print('✅ Sesión cerrada');
    } catch (e) {
      print('❌ Error en logout: $e');
    }
  }
  
  // Generar código único de empresa
  String _generateCompanyCode(String companyName) {
    final prefix = companyName.length >= 3 
        ? companyName.substring(0, 3).toUpperCase()
        : companyName.toUpperCase().padRight(3, 'X');
    final year = DateTime.now().year;
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    return '$prefix-$year-$random';
  }
  
  // Verificar si el usuario es admin
  bool get isAdmin => userRole == 'admin';
  
  // Verificar si el usuario es empleado
  bool get isEmployee => userRole == 'employee';
  
  // Método para forzar reset del loading
  void forceStopLoading() {
    _isLoading = false;
    notifyListeners();
  }
  
  // Método para verificar conexión a Firebase
  Future<bool> checkFirebaseConnection() async {
    try {
      print('🔍 Verificando conexión a Firebase...');
      await _firestore.doc('test/connection').get().timeout(
        const Duration(seconds: 5),
      );
      print('✅ Conexión Firebase OK');
      return true;
    } catch (e) {
      print('❌ Error de conexión Firebase: $e');
      return false;
    }
  }
  
  // Limpiar error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }
  
  // Parsear errores de Firebase para mostrar mensajes amigables
  String _parseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No existe una cuenta con este email';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'invalid-email':
          return 'Email inválido';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Intenta más tarde';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con este email';
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'network-request-failed':
          return 'Error de conexión. Verifica tu internet';
        case 'invalid-credential':
          return 'Credenciales inválidas';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Sin permisos para acceder a los datos';
        case 'unavailable':
          return 'Servicio no disponible. Intenta más tarde';
        case 'network-request-failed':
          return 'Error de conexión. Verifica tu internet';
        default:
          return 'Error de Firebase: ${error.message}';
      }
    } else if (error is TimeoutException) {
      return 'Tiempo de espera agotado. Verifica tu conexión';
    } else {
      return 'Error inesperado: ${error.toString()}';
    }
  }
}
