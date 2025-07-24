import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio de emergencia para arreglar datos de Firestore
class EmergencyFixService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Arregla una empresa existente añadiendo los campos members y admins
  static Future<void> fixExistingCompany() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('ERROR: No hay usuario autenticado');
        return;
      }

      print('Buscando empresa del usuario...');
      
      // Buscar el documento del usuario
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        print('ERROR: No se encontró documento del usuario');
        return;
      }

      final companyId = userDoc.data()?['companyId'];
      if (companyId == null) {
        print('ERROR: Usuario sin empresa asignada');
        return;
      }

      print('Empresa encontrada: $companyId');

      // Obtener documento de la empresa
      final companyRef = _firestore.collection('companies').doc(companyId);
      final companyDoc = await companyRef.get();

      if (!companyDoc.exists) {
        print('ERROR: No se encontró la empresa');
        return;
      }

      final companyData = companyDoc.data()!;
      bool needsUpdate = false;
      Map<String, dynamic> updates = {};

      // Verificar y añadir campo members
      if (!companyData.containsKey('members')) {
        print('Añadiendo campo members...');
        updates['members'] = [user.uid];
        needsUpdate = true;
      } else {
        final members = List<String>.from(companyData['members']);
        if (!members.contains(user.uid)) {
          print('Añadiendo usuario a members...');
          updates['members'] = FieldValue.arrayUnion([user.uid]);
          needsUpdate = true;
        }
      }

      // Verificar y añadir campo admins
      if (!companyData.containsKey('admins')) {
        print('Añadiendo campo admins...');
        updates['admins'] = [user.uid];
        needsUpdate = true;
      }

      // Aplicar actualizaciones si es necesario
      if (needsUpdate) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await companyRef.update(updates);
        print('✅ Empresa actualizada correctamente');
      } else {
        print('✅ La empresa ya tiene los campos correctos');
      }

    } catch (e) {
      print('ERROR: $e');
    }
  }

  /// Crea una empresa completamente nueva para el usuario actual
  static Future<void> createNewCompanyForCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('ERROR: No hay usuario autenticado');
        return;
      }

      print('Creando nueva empresa para usuario: ${user.email}');

      // Generar código único
      final companyCode = 'RES-2025-${DateTime.now().millisecondsSinceEpoch % 10000}';

      // Crear empresa
      final companyRef = await _firestore.collection('companies').add({
        'name': 'Mi Restaurante',
        'code': companyCode,
        'adminEmail': user.email,
        'adminId': user.uid,
        'members': [user.uid],  // IMPORTANTE
        'admins': [user.uid],   // IMPORTANTE
        'address': 'Dirección de prueba',
        'phone': '+34 666 123 456',
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

      // Actualizar usuario
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName ?? 'Admin',
        'email': user.email,
        'role': 'admin',
        'companyId': companyRef.id,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Crear empleado
      await _firestore
          .collection('companies')
          .doc(companyRef.id)
          .collection('employees')
          .doc(user.uid)
          .set({
        'name': user.displayName ?? 'Admin',
        'email': user.email,
        'role': 'admin',
        'isActive': true,
        'permissions': {
          'canCreateOrders': true,
          'canApproveOrders': true,
          'canManageEmployees': true,
          'canManageSuppliers': true,
          'canManageProducts': true,
          'canViewAnalytics': true,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Empresa creada exitosamente');
      print('   ID: ${companyRef.id}');
      print('   Código: $companyCode');

      // Crear algunos datos de prueba
      await _createSampleData(companyRef.id);

    } catch (e) {
      print('ERROR: $e');
    }
  }

  /// Crea datos de prueba en la empresa
  static Future<void> _createSampleData(String companyId) async {
    try {
      // Crear proveedor de prueba
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .add({
        'name': 'Proveedor de Prueba',
        'email': 'proveedor@test.com',
        'phone': '+34 666 111 222',
        'address': 'Calle Test 123',
        'deliveryDays': ['Lunes', 'Miércoles', 'Viernes'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Crear producto de prueba
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('products')
          .add({
        'name': 'Producto de Prueba',
        'category': 'General',
        'price': 10.50,
        'unit': 'kg',
        'supplierId': 'test_supplier',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Datos de prueba creados');

    } catch (e) {
      print('ERROR creando datos de prueba: $e');
    }
  }
}

/// Widget para ejecutar las correcciones
class EmergencyFixWidget extends StatelessWidget {
  const EmergencyFixWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corrección de Emergencia'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🚨 HERRAMIENTAS DE EMERGENCIA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Arreglando empresa...')),
                );
                await EmergencyFixService.fixExistingCompany();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Proceso completado'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Arreglar Empresa Existente\n(Añade campos members/admins)',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Creando empresa nueva...')),
                );
                await EmergencyFixService.createNewCompanyForCurrentUser();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Empresa creada'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Crear Empresa Nueva\n(Con todos los campos correctos)',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            const Card(
              color: Colors.yellow,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '⚠️ IMPORTANTE:\n'
                  '1. Revisa la consola para ver los resultados\n'
                  '2. Después de ejecutar, reinicia la app\n'
                  '3. Si falla, borra todo en Firebase y vuelve a registrarte',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
