import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeesDiagnosticWidget extends StatefulWidget {
  const EmployeesDiagnosticWidget({super.key});

  @override
  State<EmployeesDiagnosticWidget> createState() => _EmployeesDiagnosticWidgetState();
}

class _EmployeesDiagnosticWidgetState extends State<EmployeesDiagnosticWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Map<String, dynamic> diagnosticInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      isLoading = true;
      diagnosticInfo.clear();
    });

    try {
      // 1. Verificar usuario actual
      final currentUser = _auth.currentUser;
      diagnosticInfo['currentUser'] = {
        'isAuthenticated': currentUser != null,
        'uid': currentUser?.uid,
        'email': currentUser?.email,
      };

      if (currentUser != null) {
        // 2. Verificar documento del usuario
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();
          
          diagnosticInfo['userDocument'] = {
            'exists': userDoc.exists,
            'data': userDoc.exists ? userDoc.data() : null,
          };

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final companyId = userData['companyId'];
            
            // 3. Verificar empresa
            if (companyId != null) {
              try {
                final companyDoc = await _firestore
                    .collection('companies')
                    .doc(companyId)
                    .get();
                
                diagnosticInfo['company'] = {
                  'exists': companyDoc.exists,
                  'companyId': companyId,
                  'data': companyDoc.exists ? companyDoc.data() : null,
                };

                // 4. Verificar empleados en subcolección
                try {
                  final employeesSnapshot = await _firestore
                      .collection('companies')
                      .doc(companyId)
                      .collection('employees')
                      .limit(5)
                      .get();
                  
                  diagnosticInfo['employeesSubcollection'] = {
                    'count': employeesSnapshot.docs.length,
                    'employees': employeesSnapshot.docs.map((doc) => {
                      'id': doc.id,
                      'data': doc.data(),
                    }).toList(),
                  };
                } catch (e) {
                  diagnosticInfo['employeesSubcollection'] = {
                    'error': e.toString(),
                  };
                }

                // 5. Verificar usuarios con mismo companyId
                try {
                  final usersWithCompanySnapshot = await _firestore
                      .collection('users')
                      .where('companyId', isEqualTo: companyId)
                      .limit(10)
                      .get();
                  
                  diagnosticInfo['usersWithCompanyId'] = {
                    'count': usersWithCompanySnapshot.docs.length,
                    'users': usersWithCompanySnapshot.docs.map((doc) => {
                      'id': doc.id,
                      'name': doc.data()['name'],
                      'email': doc.data()['email'],
                      'role': doc.data()['role'],
                    }).toList(),
                  };
                } catch (e) {
                  diagnosticInfo['usersWithCompanyId'] = {
                    'error': e.toString(),
                  };
                }
              } catch (e) {
                diagnosticInfo['company'] = {
                  'error': e.toString(),
                };
              }
            } else {
              diagnosticInfo['company'] = {
                'error': 'Usuario no tiene companyId',
              };
            }
          }
        } catch (e) {
          diagnosticInfo['userDocument'] = {
            'error': e.toString(),
          };
        }
      }
    } catch (e) {
      diagnosticInfo['generalError'] = e.toString();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico Empleados'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Text(
                  'Diagnóstico del Sistema',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _runDiagnostic,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDiagnosticSection('Usuario Actual', diagnosticInfo['currentUser']),
                      _buildDiagnosticSection('Documento Usuario', diagnosticInfo['userDocument']),
                      _buildDiagnosticSection('Empresa', diagnosticInfo['company']),
                      _buildDiagnosticSection('Empleados (Subcolección)', diagnosticInfo['employeesSubcollection']),
                      _buildDiagnosticSection('Usuarios con CompanyId', diagnosticInfo['usersWithCompanyId']),
                      if (diagnosticInfo['generalError'] != null)
                        _buildDiagnosticSection('Error General', diagnosticInfo['generalError']),
                    ],
                  ),
                ),
              ),
              
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createSampleData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Crear Datos de Prueba'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticSection(String title, dynamic data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data?.toString() ?? 'null',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSampleData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Obtener o crear companyId
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      String companyId;
      
      if (userDoc.exists && userDoc.data()!['companyId'] != null) {
        companyId = userDoc.data()!['companyId'];
      } else {
        companyId = _firestore.collection('companies').doc().id;
        
        // Actualizar usuario con companyId
        await _firestore.collection('users').doc(currentUser.uid).set({
          'name': currentUser.displayName ?? 'Usuario Actual',
          'email': currentUser.email ?? '',
          'role': 'admin',
          'companyId': companyId,
          'isActive': true,
          'joinDate': Timestamp.now(),
        }, SetOptions(merge: true));
        
        // Crear documento de empresa
        await _firestore.collection('companies').doc(companyId).set({
          'name': 'Mi Restaurante Demo',
          'adminId': currentUser.uid,
          'members': [currentUser.uid],
          'admins': [currentUser.uid],
          'createdAt': Timestamp.now(),
        });
      }

      // Crear empleados de prueba en la subcolección
      final batch = _firestore.batch();
      
      final sampleEmployees = [
        {
          'name': 'María García',
          'email': 'maria@mirestaurante.com',
          'role': 'employee',
          'position': 'Cocinera',
          'isActive': true,
        },
        {
          'name': 'Carlos Ruiz',
          'email': 'carlos@mirestaurante.com',
          'role': 'employee',
          'position': 'Camarero',
          'isActive': true,
        },
        {
          'name': 'Ana López',
          'email': 'ana@mirestaurante.com',
          'role': 'employee',
          'position': 'Ayudante Cocina',
          'isActive': false,
        },
      ];

      for (int i = 0; i < sampleEmployees.length; i++) {
        final employeeData = sampleEmployees[i];
        final employeeRef = _firestore
            .collection('companies')
            .doc(companyId)
            .collection('employees')
            .doc('demo_employee_$i');

        batch.set(employeeRef, {
          ...employeeData,
          'companyId': companyId,
          'joinDate': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 30 + i * 10))
          ),
          'ordersCount': i * 3,
          'createdAt': Timestamp.now(),
        });
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos de prueba creados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Reejecutar diagnóstico
      _runDiagnostic();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
