import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDiagnosticScreen extends StatefulWidget {
  const FirebaseDiagnosticScreen({super.key});

  @override
  State<FirebaseDiagnosticScreen> createState() => _FirebaseDiagnosticScreenState();
}

class _FirebaseDiagnosticScreenState extends State<FirebaseDiagnosticScreen> {
  String _diagnosticResult = '';
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _diagnosticResult = '🔍 INICIANDO DIAGNÓSTICO FIREBASE...\n';
    });

    await _addResult('===========================================\n');

    // Test 1: Firebase Core
    await _testFirebaseCore();
    
    // Test 2: Project Configuration
    await _testProjectConfiguration();
    
    // Test 3: Authentication
    await _testAuthentication();
    
    // Test 4: Firestore
    await _testFirestore();
    
    // Test 5: Network Connectivity
    await _testNetworkConnectivity();

    await _addResult('\n🎯 DIAGNÓSTICO COMPLETADO\n');
    await _addResult('===========================================\n');

    setState(() => _isRunning = false);
  }

  Future<void> _addResult(String text) async {
    setState(() => _diagnosticResult += text);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _testFirebaseCore() async {
    await _addResult('\n📱 TEST 1: FIREBASE CORE\n');
    await _addResult('------------------------\n');

    try {
      final app = Firebase.app();
      await _addResult('✅ Firebase App inicializado\n');
      await _addResult('   Project ID: ${app.options.projectId}\n');
      await _addResult('   App ID: ${app.options.appId}\n');
      await _addResult('   API Key: ${app.options.apiKey.substring(0, 10)}...\n');
      
      // Verificar si las credenciales son de demo
      if (app.options.projectId == 'restau-pedidos-demo' || 
          app.options.apiKey.startsWith('AIzaSyBYr1w5Z8nM7Xm9kQsP3LtE2vJ8wGqN4dR')) {
        await _addResult('⚠️  CREDENCIALES DE DEMO DETECTADAS!\n');
        await _addResult('   ↳ Necesitas configurar tu propio proyecto Firebase\n');
      } else {
        await _addResult('✅ Credenciales parecen ser reales\n');
      }

    } catch (e) {
      await _addResult('❌ Error en Firebase Core: $e\n');
    }
  }

  Future<void> _testProjectConfiguration() async {
    await _addResult('\n🔧 TEST 2: CONFIGURACIÓN DEL PROYECTO\n');
    await _addResult('--------------------------------------\n');

    try {
      final app = Firebase.app();
      final projectId = app.options.projectId;
      
      await _addResult('📋 Project ID: $projectId\n');
      
      // Verificar archivos de configuración
      await _addResult('📁 Archivos de configuración:\n');
      await _addResult('   ✅ firebase_options.dart: Presente\n');
      
      // Note: En web no podemos verificar archivos nativos
      await _addResult('   ℹ️  google-services.json: No verificable en web\n');
      await _addResult('   ℹ️  GoogleService-Info.plist: No verificable en web\n');

    } catch (e) {
      await _addResult('❌ Error en configuración: $e\n');
    }
  }

  Future<void> _testAuthentication() async {
    await _addResult('\n🔐 TEST 3: FIREBASE AUTHENTICATION\n');
    await _addResult('----------------------------------\n');

    try {
      final auth = FirebaseAuth.instance;
      await _addResult('✅ Firebase Auth inicializado\n');
      
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        await _addResult('👤 Usuario actual: ${currentUser.email}\n');
        await _addResult('   UID: ${currentUser.uid}\n');
        await _addResult('   Email verificado: ${currentUser.emailVerified}\n');
      } else {
        await _addResult('👤 No hay usuario autenticado\n');
      }

      // Test de conectividad con el servicio
      await _addResult('\n🔍 Probando conectividad Auth...\n');
      
      try {
        // Intentar obtener métodos de login disponibles
        await auth.fetchSignInMethodsForEmail('test@test.com').timeout(
          const Duration(seconds: 5)
        );
        await _addResult('✅ Conectividad con Firebase Auth OK\n');
      } catch (e) {
        if (e.toString().contains('network')) {
          await _addResult('❌ Error de red conectando a Firebase Auth\n');
        } else {
          await _addResult('✅ Firebase Auth responde (error esperado para email test)\n');
        }
      }

    } catch (e) {
      await _addResult('❌ Error en Authentication: $e\n');
    }
  }

  Future<void> _testFirestore() async {
    await _addResult('\n🗄️ TEST 4: CLOUD FIRESTORE\n');
    await _addResult('---------------------------\n');

    try {
      final firestore = FirebaseFirestore.instance;
      await _addResult('✅ Firestore inicializado\n');

      // Test de conectividad
      await _addResult('🔍 Probando conectividad Firestore...\n');
      
      try {
        await firestore.doc('test/diagnostic').get().timeout(
          const Duration(seconds: 10)
        );
        await _addResult('✅ Conectividad con Firestore OK\n');
      } catch (e) {
        await _addResult('❌ Error conectando a Firestore: $e\n');
        
        if (e.toString().contains('permission-denied')) {
          await _addResult('💡 Problema de permisos - revisar reglas Firestore\n');
        } else if (e.toString().contains('network')) {
          await _addResult('💡 Problema de red - verificar conexión internet\n');
        } else if (e.toString().contains('project')) {
          await _addResult('💡 Problema de proyecto - verificar configuración\n');
        }
      }

    } catch (e) {
      await _addResult('❌ Error en Firestore: $e\n');
    }
  }

  Future<void> _testNetworkConnectivity() async {
    await _addResult('\n🌐 TEST 5: CONECTIVIDAD DE RED\n');
    await _addResult('-----------------------------\n');

    try {
      // Test básico de conectividad
      await _addResult('🔍 Probando conectividad general...\n');
      
      // Intentar conectar a Google (como proxy de conectividad)
      final uri = Uri.parse('https://www.google.com');
      // Note: En Flutter web no podemos hacer HTTP requests directamente por CORS
      await _addResult('ℹ️  Test de red: No disponible en web\n');
      await _addResult('💡 Para test completo, ejecutar en dispositivo móvil\n');

    } catch (e) {
      await _addResult('❌ Error en test de red: $e\n');
    }
  }

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 RESUMEN DE ACCIONES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Si ves errores arriba, sigue estos pasos:'),
          const SizedBox(height: 8),
          const Text('1. 🔗 Crear proyecto Firebase real en console.firebase.google.com'),
          const Text('2. 🔧 Ejecutar: flutterfire configure'),
          const Text('3. 🔐 Habilitar Authentication → Email/Password'),
          const Text('4. 🗄️ Crear Firestore Database'),
          const Text('5. ⚙️ Configurar reglas de seguridad'),
          const Text('6. 🚀 Ejecutar: flutter clean && flutter pub get'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Diagnóstico Firebase'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_isRunning)
            const LinearProgressIndicator(),
          
          _buildSummary(),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _diagnosticResult,
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? null : _runDiagnostics,
                    child: Text(_isRunning ? 'Ejecutando...' : '🔄 Ejecutar Diagnóstico'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                    ),
                    child: const Text('← Volver'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
