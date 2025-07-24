import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/notification_service.dart';
import '../../shared/models/user_model.dart';


/// Provider para manejar la autenticación y estado del usuario en RestauPedidos
class RestauAuthProvider extends ChangeNotifier {
  // === INSTANCIAS FIREBASE ===
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === ESTADO PRIVADO ===
  firebase_auth.User? _user;
  UserModel? _currentUser;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _companyData;
  bool _isLoading = true;
  String? _errorMessage;

  // === GETTERS PÚBLICOS ===
  firebase_auth.User? get user => _user;
  UserModel? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get companyData => _companyData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userData?['role'];
  String? get companyId => _userData?['companyId'];
  String? get companyName => _companyData?['name'];
  String? get companyCode => _companyData?['code'];

  // === GETTERS DE ROLES ===
  bool get isAdmin => userRole == 'admin';
  bool get isEmployee => userRole == 'employee';
  bool get isAuthenticated => _user != null && _userData != null;

  // === CONSTRUCTOR ===
  RestauAuthProvider() {
    _init();
  }

  // === MÉTODOS DE INICIALIZACIÓN ===

  /// Inicializa el listener de cambios de autenticación
  Future<void> _init() async {
    _auth.authStateChanges().listen(_onAuthStateChanged, onError: _onAuthError);
  }

  /// Maneja cambios en el estado de autenticación de forma segura
  Future<void> _onAuthStateChanged(firebase_auth.User? user) async {
    _setLoadingState(true);

    try {
      _user = user;
      _clearError();

      if (user != null) {
        await _loadUserDataWithRetry();

        // ✅ AÑADE ESTA LÍNEA AQUÍ
        await NotificationService().saveTokenToDatabase(user.uid);

      } else {
        _clearLocalData();
      }
    } catch (e) {
      _handleError('Error inesperado en el flujo de autenticación: $e');
      _clearLocalData();
      if (_user != null) await _auth.signOut();
    } finally {
      _setLoadingState(false);
    }
  }

  /// Maneja errores en el listener de autenticación
  void _onAuthError(dynamic error) {
    _handleError('Error crítico en el stream de autenticación: $error');
    _setLoadingState(false);
  }

  // === MÉTODOS DE CARGA DE DATOS ===

  /// Carga los datos del usuario y de la empresa con lógica de reintentos.
  Future<void> _loadUserDataWithRetry() async {
    if (_user == null) return;

    try {
      DocumentSnapshot? userDoc;
      int retries = 0;
      const maxRetries = 3;

      do {
        userDoc = await _firestore.collection('users').doc(_user!.uid).get();
        if (!userDoc.exists && retries < maxRetries) {
          retries++;
          await Future.delayed(Duration(seconds: retries));
        }
      } while (!userDoc.exists && retries < maxRetries);

      if (userDoc.exists) {
        _userData = userDoc.data() as Map<String, dynamic>?;
        _currentUser = UserModel.fromMap(_user!.uid, _userData!);

        if (_userData?['companyId'] != null) {
          final companyDoc = await _firestore.collection('companies').doc(_userData!['companyId']).get();
          if (companyDoc.exists) {
            _companyData = companyDoc.data();
          } else {
            throw Exception('La empresa con ID ${_userData!['companyId']} no fue encontrada.');
          }
        }
      } else {
        throw Exception('Datos de usuario no encontrados tras ${maxRetries} intentos.');
      }
    } catch (e) {
      _handleError('Error cargando datos del usuario: ${e.toString()}');
      _clearLocalData();
      await _auth.signOut();
    }
  }

  // === MÉTODOS DE AUTENTICACIÓN ===

  Future<AuthResult> registerCompany({
    required String companyName,
    required String adminEmail,
    required String adminPassword,
    required String adminName,
    String? address,
    String? phone,
  }) async {
    try {
      _setLoadingState(true);
      _clearError();

      if (!_isValidEmail(adminEmail)) throw Exception('Email no válido');
      if (!_isValidPassword(adminPassword)) throw Exception('La contraseña debe tener al menos 8 caracteres');

      print('=== INICIANDO REGISTRO DE EMPRESA ===');
      print('Creando usuario en Firebase Auth...');

      final credential = await _auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword
      );
      final userId = credential.user!.uid;

      print('Usuario creado con UID: $userId');
      print('Generando código de empresa...');

      final companyCode = await _generateUniqueCompanyCode(companyName);
      print('Código generado: $companyCode');

      final companyRef = _firestore.collection('companies').doc();
      final userRef = _firestore.collection('users').doc(userId);
      final employeeRef = companyRef.collection('employees').doc(userId);

      print('Creando documentos en Firestore...');

      final batch = _firestore.batch();

      // Crear documento de empresa con campos members y admins
      batch.set(companyRef, {
        'name': companyName,
        'code': companyCode,
        'adminEmail': adminEmail,
        'adminId': userId,
        'members': [userId], // 🔥 CRÍTICO: Campo members
        'admins': [userId],  // 🔥 CRÍTICO: Campo admins
        'address': address,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'settings': {
          'employeeOrderLimits': false,
          'maxOrderAmount': 500.0,
          'monthlyLimitPerEmployee': 2000.0,
          'currency': 'EUR',
          'requireApproval': true,
        },
      });

      // Crear documento de usuario
      batch.set(userRef, {
        'name': adminName,
        'email': adminEmail,
        'role': 'admin',
        'companyId': companyRef.id,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Crear documento de empleado
      batch.set(employeeRef, {
        'name': adminName,
        'email': adminEmail,
        'role': 'admin',
        'isActive': true,
        'permissions': {
          'canCreateOrders': true,
          'canApproveOrders': true,
          'canManageEmployees': true,
          'canManageSuppliers': true,
          'canManageProducts': true,
          'canViewAnalytics': true,
          'maxOrderAmount': double.infinity,
          'monthlyLimit': double.infinity,
        },
        'stats': {
          'totalOrders': 0,
          'totalAmount': 0.0,
          'monthlyOrders': 0,
          'monthlyAmount': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      print('✅ EMPRESA CREADA EXITOSAMENTE');
      print('Company ID: ${companyRef.id}');
      print('Company Code: $companyCode');

      await _loadUserDataWithRetry();


      return AuthResult.success(data: {'companyCode': companyCode});
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ ERROR DE FIREBASE AUTH: ${e.code} - ${e.message}');
      _setLoadingState(false);
      return AuthResult.error(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      print('❌ ERROR GENERAL: $e');
      _setLoadingState(false);
      return AuthResult.error(e.toString());
    }
  }

  /// 🔥 MÉTODO CORREGIDO: Registro de empleado con orden correcto de operaciones
  Future<AuthResult> registerEmployee({
    required String companyCode,
    required String email,
    required String password,
    required String name,
    String? position,
  }) async {
    firebase_auth.UserCredential? credential;

    try {
      _setLoadingState(true);
      _clearError();

      print('=== INICIANDO REGISTRO DE EMPLEADO ===');
      print('Email: $email');
      print('Código empresa: $companyCode');

      if (!_isValidEmail(email)) throw Exception('Email no válido');
      if (!_isValidPassword(password)) throw Exception('La contraseña debe tener al menos 8 caracteres');

      // PASO 1: Crear usuario en Firebase Auth PRIMERO
      print('Paso 1: Creando usuario en Firebase Auth...');
      credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      final userId = credential.user!.uid;
      print('✅ Usuario creado con UID: $userId');

      // PASO 2: Ahora que está autenticado, validar código de empresa
      print('Paso 2: Validando código de empresa...');
      print('Buscando en Firestore un código EXACTAMENTE igual a: "$companyCode"');

      final companiesQuery = await _firestore
          .collection('companies')
          .where('code', isEqualTo: companyCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      print('Resultado de la búsqueda: Se encontraron ${companiesQuery.docs.length} empresas.');

      if (companiesQuery.docs.isEmpty) {
        // Si falla, eliminar el usuario creado
        print('❌ Código de empresa inválido, eliminando usuario...');
        await credential.user!.delete();
        throw Exception('Código de empresa no válido o empresa inactiva');
      }

      final companyDoc = companiesQuery.docs.first;
      final companyId = companyDoc.id;
      final companyData = companyDoc.data();

      print('✅ Empresa encontrada: ${companyData['name']} (ID: $companyId)');

      // PASO 3: Actualizar empresa para añadir el empleado a members
      print('Paso 3: Añadiendo empleado a la empresa...');
      await _firestore.collection('companies').doc(companyId).update({
        'members': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // PASO 4: Crear documentos del empleado
      print('Paso 4: Creando documentos del empleado...');
      final userRef = _firestore.collection('users').doc(userId);
      final employeeRef = _firestore.collection('companies').doc(companyId).collection('employees').doc(userId);

      final batch = _firestore.batch();

      batch.set(userRef, {
        'name': name,
        'email': email,
        'role': 'employee',
        'companyId': companyId,
        'position': position,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(employeeRef, {
        'name': name,
        'email': email,
        'role': 'employee',
        'position': position,
        'isActive': true,
        'permissions': {
          'canCreateOrders': true,
          'canApproveOrders': false,
          'canManageEmployees': false,
          'canManageSuppliers': false,
          'canManageProducts': false,
          'canViewAnalytics': false,
          'maxOrderAmount': companyData['settings']?['maxOrderAmount'] ?? 500.0,
          'monthlyLimit': companyData['settings']?['monthlyLimitPerEmployee'] ?? 2000.0,
        },
        'stats': {
          'totalOrders': 0,
          'totalAmount': 0.0,
          'monthlyOrders': 0,
          'monthlyAmount': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      print('✅ EMPLEADO REGISTRADO EXITOSAMENTE');
      print('User ID: $userId');
      print('Company ID: $companyId');

      return AuthResult.success();

    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ ERROR DE FIREBASE AUTH: ${e.code} - ${e.message}');
      _setLoadingState(false);
      return AuthResult.error(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      print('❌ ERROR GENERAL: $e');

      // Si algo falla y ya se creó el usuario, eliminarlo
      if (credential?.user != null) {
        try {
          print('🧹 Limpiando usuario creado por error...');
          await credential!.user!.delete();
          print('✅ Usuario eliminado');
        } catch (deleteError) {
          print('⚠️ No se pudo eliminar usuario: $deleteError');
        }
      }

      _setLoadingState(false);
      return AuthResult.error(e.toString());
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoadingState(true);
      _clearError();

      print('=== INICIANDO LOGIN ===');
      print('Email: $email');

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      print('✅ LOGIN EXITOSO');
      return AuthResult.success();
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ ERROR DE LOGIN: ${e.code} - ${e.message}');
      _setLoadingState(false);
      return AuthResult.error(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      print('❌ ERROR GENERAL EN LOGIN: $e');
      _setLoadingState(false);
      return AuthResult.error(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      print('=== CERRANDO SESIÓN ===');
      await _auth.signOut();
      print('✅ SESIÓN CERRADA');
    } catch (e) {
      _handleError('Error al cerrar sesión: $e');
    }
  }

  Future<AuthResult> resetPassword({required String email}) async {
    try {
      _setLoadingState(true);
      _clearError();
      await _auth.sendPasswordResetEmail(email: email);
      _setLoadingState(false);
      return AuthResult.success();
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setLoadingState(false);
      return AuthResult.error(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      _setLoadingState(false);
      return AuthResult.error(e.toString());
    }
  }

  Future<void> hideOrderFromHistory(String orderId) async {
    if (_user == null) return;

    try {
      final userRef = _firestore.collection('users').doc(_user!.uid);

      // 1. Actualiza la base de datos como antes
      await userRef.update({
        'hiddenOrderIds': FieldValue.arrayUnion([orderId])
      });

      // 2. ✅ FIX: Actualiza solo los datos locales en lugar de recargar todo
      if (_userData != null) {
        // Obtiene la lista actual de IDs ocultos (o una lista vacía si no existe)
        final List<dynamic> currentHiddenIds = List.from(_userData!['hiddenOrderIds'] ?? []);

        // Añade el nuevo ID a la lista local si no estaba ya
        if (!currentHiddenIds.contains(orderId)) {
          currentHiddenIds.add(orderId);
        }

        // Actualiza el mapa de datos del usuario localmente
        _userData!['hiddenOrderIds'] = currentHiddenIds;

        // Notifica a los widgets que escuchan (como la pantalla de historial) que deben redibujarse
        notifyListeners();
      }

    } catch (e) {
      print('Error al ocultar el pedido: $e');
      // Aquí podrías manejar el error si lo deseas
    }
  }


  // === MÉTODOS PÚBLICOS UTILITARIOS ===

  /// Fuerza el stop del loading (para casos de emergencia en UI).
  void forceStopLoading() {
    _setLoadingState(false);
  }

  /// Verifica la conexión con Firebase.
  Future<bool> checkFirebaseConnection() async {
    try {
      await _firestore.doc('_health/check').get().timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('Error de conexión Firebase: $e');
      return false;
    }
  }

  /// Recarga los datos del usuario actual.
  Future<void> refreshUserData() async {
    if (_user != null) {
      _setLoadingState(true);
      await _loadUserDataWithRetry();
      _setLoadingState(false);
    }
  }

  // === MÉTODOS UTILITARIOS Y DE ESTADO INTERNO ===
  Future<String> _generateUniqueCompanyCode(String companyName) async {
    String code;
    bool isUnique = false;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      final prefix = companyName.length >= 3 ? companyName.substring(0, 3).toUpperCase() : 'RES';
      final year = DateTime.now().year;
      final random = (DateTime.now().millisecondsSinceEpoch + attempts) % 10000;
      code = '$prefix-$year-${random.toString().padLeft(4, '0')}';

      final existingCompany = await _firestore
          .collection('companies')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      isUnique = existingCompany.docs.isEmpty;
      attempts++;
    } while (!isUnique && attempts < maxAttempts);

    if (!isUnique) throw Exception('No se pudo generar un código único de empresa');
    return code;
  }

  bool _isValidEmail(String email) => RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  bool _isValidPassword(String password) => password.length >= 8;

  String _getFirebaseAuthErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      // 💫 ERRORES DE EMAIL
      case 'user-not-found': 
        return '😱 Email no registrado\n\nEste email no existe en nuestro sistema.\n\n• Verifica que esté escrito correctamente\n• ¿Es tu primera vez? Regístrate como empleado o empresa\n• ¿Olvidaste el email? Contacta a tu administrador';
      
      case 'invalid-email': 
        return '📧 Email inválido\n\nEl formato del email no es correcto.\n\nEjemplo válido: usuario@empresa.com';
      
      case 'user-disabled': 
        return '🚫 Cuenta desactivada\n\nTu cuenta ha sido deshabilitada.\n\nContacta al administrador de tu empresa para reactivarla.';
      
      // 🔒 ERRORES DE CONTRASEÑA
      case 'wrong-password': 
        return '🔐 Contraseña incorrecta\n\n• Verifica mayúsculas y minúsculas\n• ¿Olvidaste tu contraseña? Usa "Recuperar contraseña"\n• Contacta a tu administrador si el problema persiste';
      
      case 'weak-password': 
        return '🔒 Contraseña muy débil\n\nDebe tener al menos:\n• 8 caracteres\n• Una mayúscula y una minúscula\n• Al menos un número';
      
      // 🚪 ERRORES DE REGISTRO
      case 'email-already-in-use': 
        return '📧 Email ya registrado\n\nEste email ya tiene una cuenta.\n\n• Intenta iniciar sesión\n• ¿Olvidaste tu contraseña? Usa "Recuperar contraseña"';
      
      // 🌐 ERRORES DE CONEXIÓN
      case 'network-request-failed': 
        return '🌐 Sin conexión a internet\n\nRevisa tu conexión:\n• WiFi o datos móviles\n• Intenta en unos segundos\n• Si persiste, contacta soporte';
      
      case 'too-many-requests': 
        return '⏱️ Demasiados intentos\n\nPor seguridad, debes esperar antes de intentar nuevamente.\n\nIntenta en 15 minutos o usa "Recuperar contraseña"';
      
      // 😱 ERRORES ESPECÍFICOS DE FIREBASE
      case 'invalid-credential':
        return '🔑 Credenciales incorrectas\n\nEmail o contraseña incorrectos.\n\n• Verifica que estén bien escritos\n• Prueba con "Recuperar contraseña"';
      
      case 'account-exists-with-different-credential':
        return '📧 Email ya usado\n\nEste email ya está asociado a otra cuenta.\n\nIntenta iniciar sesión directamente.';
      
      case 'requires-recent-login':
        return '🔄 Sesión expirada\n\nPor seguridad, debes iniciar sesión nuevamente.';
      
      // ⚙️ ERRORES DE CONFIGURACIÓN
      case 'app-not-authorized':
      case 'api-key-not-valid':
        return '⚙️ Error de configuración\n\nHay un problema con la app.\n\nContacta al soporte técnico.';
      
      // 🛡️ ERRORES GENERALES
      case 'internal-error':
        return '🛡️ Error interno\n\nHubo un problema temporal.\n\nIntenta nuevamente en unos minutos.';
      
      case 'popup-closed-by-user':
        return '❌ Proceso cancelado\n\nEl inicio de sesión fue cancelado.';
      
      default: 
        return '⚠️ Error inesperado\n\n${e.message ?? 'Error desconocido'}\n\nSi el problema persiste, contacta soporte con este código: ${e.code}';
    }
  }

  void _setLoadingState(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _handleError(String error) {
    _errorMessage = error;
    debugPrint(error);
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
  }

  void _clearLocalData() {
    _currentUser = null;
    _userData = null;
    _companyData = null;
  }
}

/// Resultado de operaciones de autenticación
class AuthResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? data;

  const AuthResult._({required this.success, this.error, this.data});

  factory AuthResult.success({Map<String, dynamic>? data}) => AuthResult._(success: true, data: data);
  factory AuthResult.error(String error) => AuthResult._(success: false, error: error);
}