import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../providers/suppliers_provider.dart';

class TestSuppliersScreen extends StatefulWidget {
  const TestSuppliersScreen({super.key});

  @override
  State<TestSuppliersScreen> createState() => _TestSuppliersScreenState();
}

class _TestSuppliersScreenState extends State<TestSuppliersScreen> {
  String _testResult = 'Iniciando test...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runTest();
  }

  Future<void> _runTest() async {
    setState(() {
      _testResult = 'Ejecutando tests...';
      _isLoading = true;
    });

    final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
    
    try {
      // Test 1: Verificar usuario autenticado
      if (authProvider.user == null) {
        setState(() {
          _testResult = '❌ Test falló: Usuario no autenticado';
          _isLoading = false;
        });
        return;
      }

      // Test 2: Verificar companyId
      final companyId = authProvider.companyId;
      if (companyId == null || companyId.isEmpty) {
        setState(() {
          _testResult = '❌ Test falló: CompanyId no encontrado\\nUser data: ${authProvider.userData}';
          _isLoading = false;
        });
        return;
      }

      // Test 3: Verificar conexión a Firestore
      final firestore = FirebaseFirestore.instance;
      final companyDoc = await firestore.collection('companies').doc(companyId).get();
      
      if (!companyDoc.exists) {
        setState(() {
          _testResult = '❌ Test falló: Empresa no existe en Firestore\\nCompanyId: $companyId';
          _isLoading = false;
        });
        return;
      }

      // Test 4: Verificar colección de proveedores
      final suppliersCollection = await firestore
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .get();

      // Test 5: Crear proveedor de prueba si no existe
      if (suppliersCollection.docs.isEmpty) {
        await _createTestSupplier(companyId);
      }

      // Test 6: Verificar que el stream funciona
      final stream = firestore
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .snapshots();

      await stream.first; // Esperar el primer snapshot

      setState(() {
        _testResult = '''✅ Todos los tests pasaron!

🔹 Usuario: ${authProvider.user!.email}
🔹 Rol: ${authProvider.userRole}
🔹 CompanyId: $companyId
🔹 Empresa existe: ✅
🔹 Proveedores: ${suppliersCollection.docs.length}
🔹 Stream funciona: ✅

La pantalla de proveedores debería funcionar correctamente.''';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _testResult = '❌ Test falló con error:\\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestSupplier(String companyId) async {
    final firestore = FirebaseFirestore.instance;
    
    await firestore
        .collection('companies')
        .doc(companyId)
        .collection('suppliers')
        .add({
      'name': 'Proveedor de Prueba',
      'description': 'Proveedor creado automáticamente para testing',
      'email': 'test@proveedor.com',
      'phone': '+34 900 000 000',
      'address': 'Calle Test, 123',
      'imageUrl': null,
      'deliveryDays': ['Lunes', 'Miércoles', 'Viernes'],
      'companyId': companyId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Proveedores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runTest,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Ejecutando tests...'),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultado del Test:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          _testResult,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver a Proveedores'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
