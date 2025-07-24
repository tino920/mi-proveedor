import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../providers/employees_provider.dart';

class EmployeesDiagnosticWidget extends StatefulWidget {
  const EmployeesDiagnosticWidget({super.key});

  @override
  State<EmployeesDiagnosticWidget> createState() => _EmployeesDiagnosticWidgetState();
}

class _EmployeesDiagnosticWidgetState extends State<EmployeesDiagnosticWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> diagnosticData = {};
  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                '🔍 DIAGNÓSTICO DE EMPLEADOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (isRunning)
            const Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 12),
                Text('Analizando datos...'),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _runFullDiagnostic,
              icon: const Icon(Icons.search),
              label: const Text('🚀 EJECUTAR DIAGNÓSTICO COMPLETO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),

          if (diagnosticData.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            
            Text(
              '📊 RESULTADOS DEL ANÁLISIS:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 12),
            
            ...diagnosticData.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _forceFullMigration,
                    icon: const Icon(Icons.refresh),
                    label: const Text('🔄 FORZAR MIGRACIÓN COMPLETA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _forceStreamRefresh,
                    icon: const Icon(Icons.sync),
                    label: const Text('⚡ REINICIAR STREAM'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _runFullDiagnostic() async {
    setState(() {
      isRunning = true;
      diagnosticData.clear();
    });

    try {
      final authProvider = context.read<RestauAuthProvider>();
      final companyId = authProvider.companyId;
      final currentUser = authProvider.user;

      diagnosticData['🏢 CompanyId'] = companyId ?? 'NULL';
      diagnosticData['👤 Usuario Actual'] = currentUser?.email ?? 'NULL';

      if (companyId == null) {
        diagnosticData['❌ ERROR'] = 'CompanyId es NULL - No se puede buscar empleados';
        setState(() => isRunning = false);
        return;
      }

      // 1. Contar en collection 'users'
      final usersQuery = await _firestore
          .collection('users')
          .where('companyId', isEqualTo: companyId)
          .get();
      
      diagnosticData['👥 Users Collection'] = '${usersQuery.docs.length} encontrados';
      
      if (usersQuery.docs.isNotEmpty) {
        diagnosticData['📋 Users List'] = usersQuery.docs.map((doc) => 
          '${doc.data()['name'] ?? 'Sin nombre'} (${doc.id})'
        ).join(', ');
      }

      // 2. Contar en subcollection 'employees'
      final employeesQuery = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .get();
      
      diagnosticData['👔 Employees Subcollection'] = '${employeesQuery.docs.length} encontrados';
      
      if (employeesQuery.docs.isNotEmpty) {
        diagnosticData['📋 Employees List'] = employeesQuery.docs.map((doc) => 
          '${doc.data()['name'] ?? 'Sin nombre'} (${doc.id})'
        ).join(', ');
      }

      // 3. Verificar documento company
      final companyDoc = await _firestore.collection('companies').doc(companyId).get();
      diagnosticData['🏢 Company Doc Exists'] = companyDoc.exists ? '✅ SÍ' : '❌ NO';
      
      if (companyDoc.exists) {
        final companyData = companyDoc.data();
        diagnosticData['🏢 Company Data'] = companyData?.keys.join(', ') ?? 'Vacío';
      }

      // 4. Probar query directo
      try {
        final directQuery = await _firestore
            .collection('companies')
            .doc(companyId)
            .collection('employees')
            .orderBy('joinDate', descending: true)
            .get();
        diagnosticData['🔍 Query Directo'] = '${directQuery.docs.length} docs con ordenamiento';
      } catch (e) {
        diagnosticData['❌ Error Query'] = e.toString();
        
        // Probar sin ordenamiento
        final simpleQuery = await _firestore
            .collection('companies')
            .doc(companyId)
            .collection('employees')
            .get();
        diagnosticData['🔍 Query Simple'] = '${simpleQuery.docs.length} docs sin ordenamiento';
      }

      // 5. Verificar permisos
      try {
        await _firestore
            .collection('companies')
            .doc(companyId)
            .collection('employees')
            .limit(1)
            .get();
        diagnosticData['🔐 Permisos Lectura'] = '✅ OK';
      } catch (e) {
        diagnosticData['❌ Error Permisos'] = e.toString();
      }

      // 6. Análisis de diferencias
      final usersCount = usersQuery.docs.length;
      final employeesCount = employeesQuery.docs.length;
      
      if (usersCount > employeesCount) {
        diagnosticData['⚠️ PROBLEMA'] = 'Hay $usersCount usuarios pero solo $employeesCount empleados migrados';
        diagnosticData['💡 SOLUCIÓN'] = 'Ejecutar migración completa';
      } else if (employeesCount == 0 && usersCount == 0) {
        diagnosticData['ℹ️ INFO'] = 'No hay empleados registrados en esta empresa';
      } else if (employeesCount > 0) {
        diagnosticData['✅ STATUS'] = 'Migración parece completa, puede ser problema de Stream';
      }

    } catch (e) {
      diagnosticData['❌ ERROR GENERAL'] = e.toString();
    }

    setState(() => isRunning = false);
  }

  // ⚡ NUEVO: Forzar reinicio del stream usando el provider
  Future<void> _forceStreamRefresh() async {
    setState(() => isRunning = true);

    try {
      final employeesProvider = context.read<EmployeesProvider>();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Reiniciando stream de empleados...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Usar el nuevo método del provider
      await employeesProvider.forceRefreshEmployees();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Stream reiniciado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Volver a diagnosticar
      await Future.delayed(const Duration(seconds: 2));
      await _runFullDiagnostic();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error reiniciando stream: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isRunning = false);
  }

  Future<void> _forceFullMigration() async {
    setState(() => isRunning = true);

    try {
      final authProvider = context.read<RestauAuthProvider>();
      final companyId = authProvider.companyId;

      if (companyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error: CompanyId es NULL')),
        );
        return;
      }

      // 1. Obtener todos los usuarios de la empresa
      final usersSnapshot = await _firestore
          .collection('users')
          .where('companyId', isEqualTo: companyId)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ℹ️ No hay usuarios para migrar')),
        );
        setState(() => isRunning = false);
        return;
      }

      // 2. Migrar TODOS los usuarios usando batch
      final batch = _firestore.batch();
      int migratedCount = 0;

      for (final userDoc in usersSnapshot.docs) {
        try {
          final userData = userDoc.data();
          
          // Crear documento de empleado
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
            'position': userData['position'] ?? null,
            'ordersCount': 0,
            'forceMigratedAt': Timestamp.now(),
          };
          
          batch.set(employeeRef, employeeData, SetOptions(merge: true));
          migratedCount++;
          
          print('✅ PREPARANDO MIGRACIÓN: ${userData['name']} (${userDoc.id})');
        } catch (e) {
          print('❌ ERROR preparando migración ${userDoc.id}: $e');
        }
      }

      // 3. Ejecutar batch
      await batch.commit();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Migración completa: $migratedCount empleados'),
          backgroundColor: Colors.green,
        ),
      );

      // 4. Volver a diagnosticar
      await Future.delayed(const Duration(seconds: 2));
      await _runFullDiagnostic();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error en migración: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isRunning = false);
  }
}
