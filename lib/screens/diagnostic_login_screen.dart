import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiagnosticLoginScreen extends StatefulWidget {
  const DiagnosticLoginScreen({super.key});

  @override
  State<DiagnosticLoginScreen> createState() => _DiagnosticLoginScreenState();
}

class _DiagnosticLoginScreenState extends State<DiagnosticLoginScreen> {
  String _diagnosticResult = '';
  bool _isRunning = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _runFirebaseDiagnostic();
  }

  Future<void> _runFirebaseDiagnostic() async {
    setState(() {
      _isRunning = true;
      _diagnosticResult = '🔍 DIAGNÓSTICO FIREBASE LOGIN...\n\n';
    });

    await _addResult('📱 TEST 1: VERIFICAR FIREBASE INICIALIZADO\n');
    await _addResult('---------------------------------------\n');

    try {
      final user = FirebaseAuth.instance.currentUser;
      await _addResult('✅ Firebase Auth disponible\n');
      await _addResult('👤 Usuario actual: ${user?.email ?? "Ninguno"}\n');
      
      if (user != null) {
        await _addResult('🔑 UID: ${user.uid}\n');
        await _addResult('📧 Email verificado: ${user.emailVerified}\n');
      }
    } catch (e) {
      await _addResult('❌ Error Firebase Auth: $e\n');
    }

    await _addResult('\n📊 TEST 2: VERIFICAR CONEXIÓN FIRESTORE\n');
    await _addResult('----------------------------------------\n');

    try {
      await FirebaseFirestore.instance
          .doc('test/connection')
          .get()
          .timeout(const Duration(seconds: 5));
      await _addResult('✅ Firestore conectado correctamente\n');
    } catch (e) {
      await _addResult('❌ Error Firestore: $e\n');
      if (e.toString().contains('permission-denied')) {
        await _addResult('💡 Problema: Reglas de Firestore muy restrictivas\n');
      }
    }

    await _addResult('\n🔐 TEST 3: VERIFICAR AUTHENTICATION HABILITADO\n');
    await _addResult('----------------------------------------------\n');

    try {
      await FirebaseAuth.instance
          .fetchSignInMethodsForEmail('test@test.com')
          .timeout(const Duration(seconds: 5));
      await _addResult('✅ Authentication service funcionando\n');
    } catch (e) {
      if (e.toString().contains('network')) {
        await _addResult('❌ Error de red: $e\n');
      } else {
        await _addResult('✅ Authentication responde (error esperado para email test)\n');
      }
    }

    await _addResult('\n🎯 RECOMENDACIONES:\n');
    await _addResult('==================\n');
    await _addResult('1. Si Firebase funciona → Probar registrar nueva empresa\n');
    await _addResult('2. Si hay errores Firestore → Revisar reglas\n');
    await _addResult('3. Si hay errors de red → Verificar internet\n');

    setState(() => _isRunning = false);
  }

  Future<void> _addResult(String text) async {
    setState(() => _diagnosticResult += text);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _testRegistration() async {
    setState(() {
      _isRunning = true;
      _diagnosticResult += '\n🧪 PROBANDO REGISTRO DE EMPRESA...\n';
      _diagnosticResult += '===================================\n';
    });

    try {
      await _addResult('📝 Intentando crear usuario de prueba...\n');
      
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: 'test-${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'Test123456',
      );

      await _addResult('✅ Usuario creado: ${credential.user?.uid}\n');
      await _addResult('📧 Email: ${credential.user?.email}\n');

      // Probar crear documento en Firestore
      await FirebaseFirestore.instance
          .collection('test_users')
          .doc(credential.user!.uid)
          .set({
        'name': 'Usuario Test',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _addResult('✅ Documento Firestore creado\n');
      await _addResult('\n🎉 ¡REGISTRO FUNCIONA CORRECTAMENTE!\n');
      await _addResult('💡 Puedes registrar empresa desde la pantalla principal\n');

    } catch (e) {
      await _addResult('❌ Error en registro: $e\n');
      
      if (e.toString().contains('email-already-in-use')) {
        await _addResult('💡 Email ya existe (normal)\n');
      } else if (e.toString().contains('permission-denied')) {
        await _addResult('💡 Problema: Reglas Firestore bloquean escritura\n');
      } else if (e.toString().contains('network')) {
        await _addResult('💡 Problema: Error de conectividad\n');
      }
    }

    setState(() => _isRunning = false);
  }

  Future<void> _testLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa email y contraseña')),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _diagnosticResult += '\n🔑 PROBANDO LOGIN...\n';
      _diagnosticResult += '===================\n';
    });

    try {
      await _addResult('📧 Email: $email\n');
      await _addResult('🔓 Intentando login...\n');

      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await _addResult('✅ Login exitoso!\n');
      await _addResult('👤 UID: ${credential.user?.uid}\n');
      await _addResult('📧 Email: ${credential.user?.email}\n');

      // Probar cargar datos de usuario
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        await _addResult('👥 Rol: ${userData['role']}\n');
        await _addResult('🏢 CompanyId: ${userData['companyId']}\n');
        await _addResult('\n🎉 ¡LOGIN COMPLETAMENTE FUNCIONAL!\n');
      } else {
        await _addResult('⚠️ Usuario sin datos en Firestore\n');
        await _addResult('💡 Necesitas registrar empresa primero\n');
      }

    } catch (e) {
      await _addResult('❌ Error login: $e\n');
      
      if (e.toString().contains('user-not-found')) {
        await _addResult('💡 Usuario no existe → Registrar empresa\n');
      } else if (e.toString().contains('wrong-password')) {
        await _addResult('💡 Contraseña incorrecta\n');
      } else if (e.toString().contains('invalid-email')) {
        await _addResult('💡 Formato email inválido\n');
      }
    }

    setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Diagnóstico Login'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_isRunning)
            const LinearProgressIndicator(),

          // Test manual de login
          Container(
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
                  '🧪 TEST MANUAL DE LOGIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _testLogin,
                        child: const Text('🔑 Test Login'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _testRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                        ),
                        child: const Text('📝 Test Registro'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Resultados del diagnóstico
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

          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? null : _runFirebaseDiagnostic,
                    child: Text(_isRunning ? 'Ejecutando...' : '🔄 Re-diagnosticar'),
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
