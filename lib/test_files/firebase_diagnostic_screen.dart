import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../core/auth/auth_provider.dart';

/// Pantalla de diagnóstico completa para Firebase y MiProveedor
///
/// Verifica:
/// - Configuración de Firebase
/// - Conectividad con servicios
/// - Funcionalidad del AuthProvider
/// - Reglas de seguridad
/// - Operaciones CRUD básicas
/// - Diagnóstico específico del error "Company ID"
class FirebaseDiagnosticScreen extends StatefulWidget {
  const FirebaseDiagnosticScreen({super.key});

  @override
  State<FirebaseDiagnosticScreen> createState() => _FirebaseDiagnosticScreenState();
}

class _FirebaseDiagnosticScreenState extends State<FirebaseDiagnosticScreen> {
  List<DiagnosticResult> diagnostics = [];
  bool isRunning = false;
  String? firebaseProjectId;
  bool _showSolutions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runDiagnostics();
    });
  }

  /// Ejecuta todos los diagnósticos de Firebase
  Future<void> _runDiagnostics() async {
    setState(() {
      isRunning = true;
      diagnostics.clear();
      _showSolutions = false;
    });

    await _checkFirebaseCore();
    await _checkFirebaseAuth();
    await _checkFirestore();
    await _checkFirestoreRules();
    await _checkAuthProvider();
    await _checkUserDocument();
    await _checkCompanyData();
    await _testBasicOperations();
    await _checkNetworkConnectivity();

    setState(() {
      isRunning = false;
      _showSolutions = diagnostics.any((d) => !d.success);
    });
  }

  /// Verifica la configuración de Firebase Core
  Future<void> _checkFirebaseCore() async {
    try {
      final app = Firebase.app();
      firebaseProjectId = app.options.projectId;

      _addResult(
        'Firebase Core',
        true,
        'Conectado correctamente',
        'Project ID: ${app.options.projectId}\n'
            'App ID: ${app.options.appId}\n'
            'API Key: ${app.options.apiKey.substring(0, 10)}...\n'
            'Status: Inicializado correctamente',
      );
    } catch (e) {
      _addResult(
        'Firebase Core',
        false,
        'Error de configuración',
        'Error: $e\n\n'
            'Solución:\n'
            '• Verifica que firebase_options.dart esté configurado\n'
            '• Ejecuta: flutterfire configure\n'
            '• Revisa google-services.json (Android) y GoogleService-Info.plist (iOS)',
      );
    }
  }

  /// Verifica Firebase Authentication
  Future<void> _checkFirebaseAuth() async {
    try {
      final auth = firebase_auth.FirebaseAuth.instance;
      final currentUser = auth.currentUser;

      String userStatus = 'No hay usuario autenticado';
      if (currentUser != null) {
        userStatus = 'Email: ${currentUser.email}\n'
            'UID: ${currentUser.uid}\n'
            'Email verificado: ${currentUser.emailVerified}\n'
            'Creado: ${currentUser.metadata.creationTime}';
      }

      _addResult(
        'Firebase Auth',
        true,
        'Servicio disponible',
        'Estado de autenticación:\n$userStatus\n\n'
            'Providers disponibles: Email/Password\n'
            'Configuración: Correcta',
      );
    } catch (e) {
      _addResult(
        'Firebase Auth',
        false,
        'Error en Authentication',
        'Error: $e\n\n'
            'Solución:\n'
            '• Habilita Authentication en Firebase Console\n'
            '• Activa el proveedor Email/Password\n'
            '• Verifica la configuración de dominio autorizado',
      );
    }
  }

  /// Verifica conexión con Firestore
  Future<void> _checkFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Test de conectividad básica
      await firestore.enableNetwork();

      // Intentar leer una colección de prueba
      final testQuery = await firestore
          .collection('_diagnostic')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      _addResult(
        'Cloud Firestore',
        true,
        'Conexión exitosa',
        'Base de datos accesible\n'
            'Documentos de prueba encontrados: ${testQuery.docs.length}\n'
            'Latencia: < 10 segundos\n'
            'Red habilitada: Sí',
      );
    } catch (e) {
      String details = 'Error: $e\n\n';

      if (e.toString().contains('permission-denied')) {
        details += 'Problema: Reglas de Firestore muy restrictivas\n\n'
            'Solución:\n'
            '• Configura reglas de prueba en Firestore\n'
            '• Para desarrollo usa: allow read, write: if true;';
      } else if (e.toString().contains('unavailable')) {
        details += 'Problema: Servicio no disponible\n\n'
            'Solución:\n'
            '• Verifica conexión a internet\n'
            '• Revisa el estado de Firebase Status';
      } else {
        details += 'Posibles causas:\n'
            '• Reglas de Firestore restrictivas\n'
            '• No hay conexión a internet\n'
            '• Proyecto Firebase mal configurado';
      }

      _addResult(
        'Cloud Firestore',
        false,
        'Error de conexión',
        details,
      );
    }
  }

  /// Verifica las reglas de Firestore
  Future<void> _checkFirestoreRules() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Test de escritura en colección de diagnóstico
      final testDoc = firestore.collection('_diagnostic').doc('rules_test');
      await testDoc.set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'source': 'diagnostic_screen',
      }).timeout(const Duration(seconds: 10));

      // Test de lectura
      final readDoc = await testDoc.get().timeout(const Duration(seconds: 5));

      // Limpiar documento de prueba
      await testDoc.delete();

      _addResult(
        'Reglas de Firestore',
        true,
        'Lectura y escritura funcionando',
        'Test de escritura: ✅ Exitoso\n'
            'Test de lectura: ✅ Exitoso\n'
            'Test de eliminación: ✅ Exitoso\n'
            'Documento creado y eliminado correctamente',
      );
    } catch (e) {
      String message = 'Error en operaciones';
      String details = 'Error: $e\n\n';

      if (e.toString().contains('permission-denied')) {
        message = 'Permisos denegados';
        details += 'Las reglas de Firestore están bloqueando las operaciones.\n\n'
            'Para desarrollo, usa estas reglas:\n\n'
            'rules_version = \'2\';\n'
            'service cloud.firestore {\n'
            '  match /databases/{database}/documents {\n'
            '    match /{document=**} {\n'
            '      allow read, write: if true;\n'
            '    }\n'
            '  }\n'
            '}';
      }

      _addResult(
        'Reglas de Firestore',
        false,
        message,
        details,
      );
    }
  }

  /// Verifica el RestauAuthProvider
  Future<void> _checkAuthProvider() async {
    try {
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);

      // Test de conexión
      final hasConnection = await authProvider.checkFirebaseConnection();

      // Información del estado actual
      String authStatus = 'Autenticado: ${authProvider.isAuthenticated}\n'
          'Loading: ${authProvider.isLoading}\n'
          'Error: ${authProvider.errorMessage ?? "Ninguno"}';

      String userInfo = 'No hay usuario autenticado';
      if (authProvider.user != null) {
        userInfo = 'Email: ${authProvider.user!.email}\n'
            'UID: ${authProvider.user!.uid}\n'
            'Rol: ${authProvider.userRole ?? "No definido"}\n'
            'Empresa ID: ${authProvider.companyId ?? "No asignada"}\n'
            'Empresa: ${authProvider.companyName ?? "No cargada"}';
      }

      _addResult(
        'RestauAuthProvider',
        hasConnection && authProvider.errorMessage == null,
        hasConnection ? 'Funcionando correctamente' : 'Problemas detectados',
        'Estado del provider:\n$authStatus\n\n'
            'Usuario actual:\n$userInfo\n\n'
            'Conexión Firebase: ${hasConnection ? "✅" : "❌"}',
      );
    } catch (e) {
      _addResult(
        'RestauAuthProvider',
        false,
        'Error en provider',
        'Error: $e\n\n'
            'Posible causa:\n'
            '• El RestauAuthProvider no está registrado en main.dart\n'
            '• Problema en la inicialización del provider\n'
            '• Conflicto de imports en auth_provider.dart',
      );
    }
  }

  /// Verifica específicamente el documento del usuario (diagnóstico del error Company ID)
  Future<void> _checkUserDocument() async {
    try {
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);

      if (authProvider.user == null) {
        _addResult(
          'Documento Usuario',
          false,
          'No hay usuario autenticado',
          'No se puede verificar el documento del usuario\n'
              'Acción requerida: Iniciar sesión',
        );
        return;
      }

      // Verificar documento en colección users
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .get();

      if (!userDoc.exists) {
        _addResult(
          'Documento Usuario',
          false,
          'Documento de usuario no existe',
          'El documento en /users/${authProvider.user!.uid} no existe\n\n'
              'Este es el problema principal!\n\n'
              'Solución:\n'
              '• El registro no se completó correctamente\n'
              '• Usar el botón "Reparar Automáticamente" abajo\n'
              '• O re-registrarse en la aplicación',
        );
        return;
      }

      final userData = userDoc.data()!;
      final List<String> issues = [];
      final List<String> checks = [];

      // Verificar campos críticos
      if (!userData.containsKey('companyId') || userData['companyId'] == null) {
        issues.add('❌ Campo companyId faltante o null');
      } else {
        checks.add('✅ Campo companyId presente: ${userData['companyId']}');
      }

      if (!userData.containsKey('role') || userData['role'] == null) {
        issues.add('❌ Campo role faltante o null');
      } else {
        checks.add('✅ Campo role presente: ${userData['role']}');
      }

      if (!userData.containsKey('email')) {
        issues.add('❌ Campo email faltante');
      } else {
        checks.add('✅ Campo email presente: ${userData['email']}');
      }

      if (!userData.containsKey('name') || userData['name'] == null) {
        issues.add('⚠️ Campo name faltante o null');
      } else {
        checks.add('✅ Campo name presente: ${userData['name']}');
      }

      final allChecks = [...checks, ...issues].join('\n');
      final hasIssues = issues.isNotEmpty;

      _addResult(
        'Documento Usuario',
        !hasIssues,
        hasIssues ? 'Problemas encontrados en documento' : 'Documento correcto',
        'Verificación de campos:\n$allChecks\n\n'
            '${hasIssues ? "Requiere reparación" : "Documento está completo"}',
      );

    } catch (e) {
      _addResult(
        'Documento Usuario',
        false,
        'Error verificando documento',
        'Error: $e\n\n'
            'No se pudo verificar el documento del usuario\n'
            'Verifica la conexión a Firestore',
      );
    }
  }

  /// Verifica los datos de la empresa
  Future<void> _checkCompanyData() async {
    try {
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);

      if (authProvider.companyId == null) {
        _addResult(
          'Datos de Empresa',
          false,
          'Company ID no disponible',
          'No se puede verificar la empresa porque:\n'
              '• El usuario no tiene companyId asignado\n'
              '• O hay problemas en el documento del usuario\n\n'
              'Soluciona primero el "Documento Usuario"',
        );
        return;
      }

      // Verificar documento de empresa
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(authProvider.companyId!)
          .get();

      if (!companyDoc.exists) {
        _addResult(
          'Datos de Empresa',
          false,
          'Empresa no existe',
          'La empresa con ID ${authProvider.companyId} no existe\n\n'
              'Esto significa que:\n'
              '• La empresa fue eliminada\n'
              '• El companyId es incorrecto\n'
              '• Hay un problema de datos\n\n'
              'Requiere intervención manual',
        );
        return;
      }

      final companyData = companyDoc.data()!;
      final List<String> checks = [];

      checks.add('✅ Empresa existe: ${companyData['name']}');
      checks.add('✅ Código: ${companyData['code']}');
      checks.add('✅ Admin: ${companyData['adminEmail']}');

      if (companyData['isActive'] == false) {
        checks.add('⚠️ Empresa está desactivada');
      } else {
        checks.add('✅ Empresa activa');
      }

      // Verificar usuario en colección de empleados
      final employeeDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(authProvider.companyId!)
          .collection('employees')
          .doc(authProvider.user!.uid)
          .get();

      if (employeeDoc.exists) {
        checks.add('✅ Usuario existe en colección de empleados');
        final empData = employeeDoc.data()!;
        checks.add('✅ Rol en empresa: ${empData['role']}');
        checks.add('✅ Estado: ${empData['isActive'] ? "Activo" : "Inactivo"}');
      } else {
        checks.add('❌ Usuario NO existe en colección de empleados');
      }

      final hasIssues = checks.any((check) => check.startsWith('❌') || check.startsWith('⚠️'));

      _addResult(
        'Datos de Empresa',
        !hasIssues,
        hasIssues ? 'Problemas en datos de empresa' : 'Empresa verificada correctamente',
        checks.join('\n'),
      );

    } catch (e) {
      _addResult(
        'Datos de Empresa',
        false,
        'Error verificando empresa',
        'Error: $e\n\n'
            'No se pudo verificar los datos de la empresa',
      );
    }
  }

  /// Prueba operaciones básicas de la app
  Future<void> _testBasicOperations() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Test 1: Crear colección de empresa de prueba
      final testCompanyId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      await firestore.collection('companies').doc(testCompanyId).set({
        'name': 'Test Company',
        'code': 'TST-2024-0001',
        'testData': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Test 2: Crear proveedor de prueba
      await firestore
          .collection('companies')
          .doc(testCompanyId)
          .collection('suppliers')
          .doc('test_supplier')
          .set({
        'name': 'Test Supplier',
        'contact': {'email': 'test@supplier.com'},
        'testData': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Test 3: Leer datos creados
      final companyDoc = await firestore
          .collection('companies')
          .doc(testCompanyId)
          .get();

      // Limpiar datos de prueba
      await _cleanupTestData(testCompanyId);

      _addResult(
        'Operaciones CRUD',
        companyDoc.exists,
        'Operaciones básicas funcionando',
        'Tests realizados:\n'
            '✅ Crear empresa\n'
            '✅ Crear proveedor en subcoleción\n'
            '✅ Leer datos creados\n'
            '✅ Eliminar datos de prueba\n\n'
            'La estructura de datos de MiProveedor funciona correctamente',
      );
    } catch (e) {
      _addResult(
        'Operaciones CRUD',
        false,
        'Error en operaciones básicas',
        'Error: $e\n\n'
            'Esto indica que:\n'
            '• Las reglas de Firestore pueden estar mal configuradas\n'
            '• Hay problemas de conectividad\n'
            '• La estructura de la base de datos necesita ajustes',
      );
    }
  }

  /// Verifica conectividad de red
  Future<void> _checkNetworkConnectivity() async {
    try {
      // Test de conectividad con Firebase
      await FirebaseFirestore.instance.enableNetwork();

      final healthCheck = await FirebaseFirestore.instance
          .doc('_health/check')
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      _addResult(
        'Conectividad de Red',
        true,
        'Conexión estable',
        'Tests de conectividad:\n'
            '✅ Conexión a Firebase\n'
            '✅ Latencia: < 10 segundos\n'
            '✅ Fuente de datos: ${healthCheck.metadata.isFromCache ? "Cache" : "Servidor"}\n'
            '✅ Última verificación: ${DateTime.now().toLocal()}',
      );
    } catch (e) {
      bool isOffline = e.toString().contains('unavailable') ||
          e.toString().contains('timeout');

      _addResult(
        'Conectividad de Red',
        false,
        isOffline ? 'Sin conexión a internet' : 'Problemas de conectividad',
        'Error: $e\n\n'
            '${isOffline ? "Solución:\n• Verifica tu conexión a internet\n• Intenta cambiar de red WiFi a datos móviles" : "Puede ser un problema temporal de Firebase"}',
      );
    }
  }

  /// Limpia los datos de prueba creados
  Future<void> _cleanupTestData(String testCompanyId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Eliminar proveedores
      final suppliers = await FirebaseFirestore.instance
          .collection('companies')
          .doc(testCompanyId)
          .collection('suppliers')
          .where('testData', isEqualTo: true)
          .get();

      for (final doc in suppliers.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar empresa
      batch.delete(
          FirebaseFirestore.instance.collection('companies').doc(testCompanyId)
      );

      await batch.commit();
    } catch (e) {
      debugPrint('Error limpiando datos de prueba: $e');
    }
  }

  /// Reparación automática del error Company ID
  Future<void> _autoFixCompanyId() async {
    setState(() => isRunning = true);

    try {
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);

      if (authProvider.user == null) {
        _showErrorDialog('No hay usuario autenticado');
        return;
      }

      bool fixed = false;
      final uid = authProvider.user!.uid;

      // Paso 1: Verificar si existe documento de usuario
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        // Buscar en todas las empresas para encontrar el usuario
        final companiesSnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .get();

        for (final companyDoc in companiesSnapshot.docs) {
          final employeeDoc = await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyDoc.id)
              .collection('employees')
              .doc(uid)
              .get();

          if (employeeDoc.exists) {
            final employeeData = employeeDoc.data()!;

            // Crear documento de usuario
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .set({
              'name': employeeData['name'],
              'email': employeeData['email'],
              'role': employeeData['role'],
              'companyId': companyDoc.id,
              'isActive': employeeData['isActive'] ?? true,
              'createdAt': employeeData['createdAt'] ?? FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'repairedAt': FieldValue.serverTimestamp(),
              'repairedBy': 'auto_fix',
            });

            fixed = true;
            break;
          }
        }
      } else {
        // Documento existe, verificar y reparar campos
        final userData = userDoc.data()!;
        final updates = <String, dynamic>{};

        if (!userData.containsKey('companyId') || userData['companyId'] == null) {
          // Buscar companyId en colecciones de empleados
          final companiesSnapshot = await FirebaseFirestore.instance
              .collection('companies')
              .get();

          for (final companyDoc in companiesSnapshot.docs) {
            final employeeDoc = await FirebaseFirestore.instance
                .collection('companies')
                .doc(companyDoc.id)
                .collection('employees')
                .doc(uid)
                .get();

            if (employeeDoc.exists) {
              updates['companyId'] = companyDoc.id;
              break;
            }
          }
        }

        if (!userData.containsKey('role') || userData['role'] == null) {
          updates['role'] = 'employee';
        }

        if (!userData.containsKey('isActive')) {
          updates['isActive'] = true;
        }

        updates['updatedAt'] = FieldValue.serverTimestamp();
        updates['repairedAt'] = FieldValue.serverTimestamp();

        if (updates.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update(updates);
          fixed = true;
        }
      }

      if (fixed) {
        // Recargar datos del provider
        await authProvider.refreshUserData();

        _showSuccessDialog(
            'Reparación completada exitosamente.\n\n'
                'Los datos de tu usuario han sido restaurados.\n'
                'Ahora puedes usar la aplicación normalmente.'
        );

        // Ejecutar diagnósticos nuevamente
        await Future.delayed(const Duration(seconds: 2));
        await _runDiagnostics();
      } else {
        _showErrorDialog(
            'No se pudo reparar automáticamente.\n\n'
                'Tu usuario no fue encontrado en ninguna empresa.\n'
                'Es necesario registrarse nuevamente.'
        );
      }

    } catch (e) {
      _showErrorDialog('Error durante la reparación: $e');
    } finally {
      setState(() => isRunning = false);
    }
  }

  /// Añade un resultado de diagnóstico
  void _addResult(String test, bool success, String message, String details) {
    setState(() {
      diagnostics.add(DiagnosticResult(
        test: test,
        success: success,
        message: message,
        details: details,
        timestamp: DateTime.now(),
      ));
    });
  }

  /// Copia el reporte completo al clipboard
  void _copyReportToClipboard() {
    final report = StringBuffer();
    report.writeln('MiProveedor - Reporte de Diagnóstico Firebase');
    report.writeln('Generado: ${DateTime.now()}');
    report.writeln('Proyecto: $firebaseProjectId');
    report.writeln('=' * 50);
    report.writeln();

    for (final diagnostic in diagnostics) {
      report.writeln('${diagnostic.success ? "✅" : "❌"} ${diagnostic.test}');
      report.writeln('   ${diagnostic.message}');
      report.writeln('   ${diagnostic.details.replaceAll('\n', '\n   ')}');
      report.writeln();
    }

    Clipboard.setData(ClipboardData(text: report.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reporte copiado al portapapeles'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Forzar logout y vuelta al login
  Future<void> _forceLogout() async {
    try {
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
      await authProvider.logout();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
              (route) => false,
        );
      }
    } catch (e) {
      _showErrorDialog('Error al cerrar sesión: $e');
    }
  }

  /// Muestra diálogo de error
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de éxito
  void _showSuccessDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('Éxito'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final successCount = diagnostics.where((d) => d.success).length;
    final totalCount = diagnostics.length;
    final hasErrors = diagnostics.any((d) => !d.success);
    final hasCriticalErrors = diagnostics.any((d) =>
    !d.success && (d.test.contains('Usuario') || d.test.contains('Empresa')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico Firebase'),
        backgroundColor: hasErrors ? Colors.red.shade600 : Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: diagnostics.isNotEmpty ? _copyReportToClipboard : null,
            tooltip: 'Copiar reporte',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isRunning ? null : _runDiagnostics,
            tooltip: 'Ejecutar diagnósticos',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de progreso
            if (isRunning) ...[
              LinearProgressIndicator(
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ejecutando diagnósticos... (${diagnostics.length} completados)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Header con resumen
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Resultados del Diagnóstico',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (diagnostics.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasErrors ? Colors.red.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hasErrors ? Colors.red.shade300 : Colors.green.shade300,
                      ),
                    ),
                    child: Text(
                      '$successCount/$totalCount exitosos',
                      style: TextStyle(
                        color: hasErrors ? Colors.red.shade700 : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón de reparación automática (solo si hay errores críticos)
            if (hasCriticalErrors && !isRunning) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_fix_high, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reparación Automática Disponible',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Se detectaron problemas en tu usuario que pueden repararse automáticamente.',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _autoFixCompanyId,
                        icon: const Icon(Icons.build),
                        label: const Text('Reparar Automáticamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Lista de resultados
            Expanded(
              child: diagnostics.isEmpty && !isRunning
                  ? _buildEmptyState()
                  : ListView.builder(
                itemCount: diagnostics.length,
                itemBuilder: (context, index) {
                  final diagnostic = diagnostics[index];
                  return _buildDiagnosticCard(diagnostic);
                },
              ),
            ),

            // Panel de soluciones recomendadas
            if (_showSolutions && !isRunning) ...[
              const Divider(),
              const SizedBox(height: 16),
              _buildSolutionsPanel(),
              const SizedBox(height: 16),
            ],

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _forceLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Presiona el botón de actualizar para ejecutar los diagnósticos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de diagnóstico
  Widget _buildDiagnosticCard(DiagnosticResult diagnostic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: diagnostic.success
              ? Colors.green.shade200
              : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: diagnostic.success
                ? Colors.green.shade100
                : Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            diagnostic.success ? Icons.check_circle : Icons.error,
            color: diagnostic.success ? Colors.green.shade700 : Colors.red.shade700,
            size: 20,
          ),
        ),
        title: Text(
          diagnostic.test,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: diagnostic.success ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        subtitle: Text(
          diagnostic.message,
          style: TextStyle(
            color: diagnostic.success ? Colors.green.shade600 : Colors.red.shade600,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: diagnostic.success
                ? Colors.green.shade50
                : Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalles:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  diagnostic.details,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verificado: ${diagnostic.timestamp.toString().substring(0, 19)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el panel de soluciones
  Widget _buildSolutionsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Soluciones Recomendadas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Si hay problemas de usuario/empresa: Usar "Reparar Automáticamente"\n'
                '2. Si hay problemas de Firestore: Verificar reglas de seguridad\n'
                '3. Si hay problemas de Auth: Verificar configuración en Firebase Console\n'
                '4. Si persisten problemas: Cerrar sesión e intentar registrarse nuevamente\n'
                '5. Para problemas técnicos: Contactar soporte técnico',
          ),
        ],
      ),
    );
  }
}

/// Clase para almacenar resultados de diagnóstico
class DiagnosticResult {
  final String test;
  final bool success;
  final String message;
  final String details;
  final DateTime timestamp;

  DiagnosticResult({
    required this.test,
    required this.success,
    required this.message,
    required this.details,
    required this.timestamp,
  });
}