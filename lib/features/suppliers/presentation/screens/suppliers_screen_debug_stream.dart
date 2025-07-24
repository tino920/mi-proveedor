import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/suppliers_provider.dart';
import '../widgets/add_supplier_dialog.dart';
import '../../../../shared/models/supplier_model.dart';

class SuppliersScreenDebugStream extends StatelessWidget {
  const SuppliersScreenDebugStream({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SuppliersProvider(),
      child: const _SuppliersDebugContent(),
    );
  }
}

class _SuppliersDebugContent extends StatefulWidget {
  const _SuppliersDebugContent();

  @override
  State<_SuppliersDebugContent> createState() => _SuppliersDebugContentState();
}

class _SuppliersDebugContentState extends State<_SuppliersDebugContent> {
  String _debugInfo = '';
  bool _testingFirestore = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<RestauAuthProvider>(
      builder: (context, authProvider, _) {
        final companyId = authProvider.companyId;
        
        if (companyId == null) {
          return const Scaffold(
            body: Center(child: Text('No companyId')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Debug Proveedores'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bug_report),
                onPressed: () => _testFirestoreDirectly(companyId),
              ),
            ],
          ),
          body: Column(
            children: [
              // Panel de debug info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEBUG INFO:',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CompanyId: $companyId\n'
                      'User: ${authProvider.user?.email}\n'
                      'Role: ${authProvider.userRole}\n'
                      '$_debugInfo',
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Test button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _testingFirestore ? null : () => _testFirestoreDirectly(companyId),
                        child: _testingFirestore 
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text('Test Firestore Direct'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAddSupplierDialog(context, companyId),
                        child: const Text('Añadir Proveedor'),
                      ),
                    ),
                  ],
                ),
              ),
              
              // StreamBuilder debug
              Expanded(
                child: Consumer<SuppliersProvider>(
                  builder: (context, provider, _) {
                    return StreamBuilder<List<Supplier>>(
                      stream: provider.getSuppliersStream(companyId),
                      builder: (context, snapshot) {
                        // Debug info actualizada
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _debugInfo = '''
ConnectionState: ${snapshot.connectionState}
HasError: ${snapshot.hasError}
Error: ${snapshot.error}
HasData: ${snapshot.hasData}
Data length: ${snapshot.data?.length ?? 'null'}
Provider loading: ${provider.isLoading}
Provider error: ${provider.error}
''';
                          });
                        });
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STREAM STATE:',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDebugRow('Connection State', '${snapshot.connectionState}'),
                                      _buildDebugRow('Has Error', '${snapshot.hasError}'),
                                      if (snapshot.hasError) 
                                        _buildDebugRow('Error', '${snapshot.error}', isError: true),
                                      _buildDebugRow('Has Data', '${snapshot.hasData}'),
                                      _buildDebugRow('Data Length', '${snapshot.data?.length ?? 'null'}'),
                                      _buildDebugRow('Provider Loading', '${provider.isLoading}'),
                                      if (provider.error != null)
                                        _buildDebugRow('Provider Error', '${provider.error}', isError: true),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              if (snapshot.hasError) ...[
                                Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.error, size: 48, color: Colors.red),
                                      const SizedBox(height: 16),
                                      Text('❌ Error en stream: ${snapshot.error}'),
                                    ],
                                  ),
                                ),
                              ] else if (snapshot.hasData && snapshot.data!.isNotEmpty) ...[
                                Text('✅ Stream funcionando! Proveedores: ${snapshot.data!.length}'),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      final supplier = snapshot.data![index];
                                      return Card(
                                        child: ListTile(
                                          title: Text(supplier.name),
                                          subtitle: Text('ID: ${supplier.id}'),
                                          trailing: Text(supplier.email ?? 'Sin email'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ] else if (snapshot.connectionState == ConnectionState.waiting) ...[
                                const Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('⏳ Esperando datos del stream...'),
                                    ],
                                  ),
                                ),
                              ] else if (snapshot.hasData && snapshot.data!.isEmpty) ...[
                                const Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.info, size: 48, color: Colors.blue),
                                      SizedBox(height: 16),
                                      Text('ℹ️ No hay proveedores aún'),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.info, size: 48, color: Colors.blue),
                                      SizedBox(height: 16),
                                      Text('ℹ️ Stream connected pero sin datos'),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : null,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testFirestoreDirectly(String companyId) async {
    setState(() {
      _testingFirestore = true;
      _debugInfo = 'Testing Firestore direct access...';
    });

    try {
      print('🔍 Testing Firestore direct access...');
      
      // Test 1: Check company exists
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();
      
      print('📊 Company doc exists: ${companyDoc.exists}');
      if (companyDoc.exists) {
        print('📊 Company data: ${companyDoc.data()}');
      }

      // Test 2: Get suppliers collection directly
      final suppliersSnapshot = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .get();
      
      print('📊 Suppliers count: ${suppliersSnapshot.docs.length}');
      
      for (final doc in suppliersSnapshot.docs) {
        print('📊 Supplier doc: ${doc.id}');
        print('📊 Supplier data: ${doc.data()}');
        
        try {
          final supplier = Supplier.fromFirestore(doc);
          print('✅ Supplier parsed OK: ${supplier.name}');
        } catch (e) {
          print('❌ Error parsing supplier: $e');
        }
      }

      // Test 3: Test stream directly
      print('🔍 Testing stream...');
      final stream = FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .orderBy('name')
          .snapshots();

      final streamData = await stream.first;
      print('📊 Stream first result: ${streamData.docs.length} docs');

      setState(() {
        _debugInfo = '''
DIRECT FIRESTORE TEST:
✅ Company exists: ${companyDoc.exists}
✅ Suppliers count: ${suppliersSnapshot.docs.length}
✅ Stream works: ${streamData.docs.length} docs
✅ All tests passed!

SUPPLIERS FOUND:
${suppliersSnapshot.docs.map((doc) => '- ${doc.data()['name']} (${doc.id})').join('\n')}
''';
      });

    } catch (e) {
      print('❌ Error in direct test: $e');
      setState(() {
        _debugInfo = 'ERROR in direct test: $e';
      });
    } finally {
      setState(() {
        _testingFirestore = false;
      });
    }
  }

  void _showAddSupplierDialog(BuildContext context, String companyId) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: Provider.of<SuppliersProvider>(context, listen: false),
        child: AddSupplierDialog(companyId: companyId),
      ),
    );
  }
}
