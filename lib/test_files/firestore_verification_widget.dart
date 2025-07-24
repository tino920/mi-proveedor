import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget temporal para verificar la configuración de Firestore
/// 
/// Añade esto temporalmente en tu main.dart o en cualquier pantalla
/// para verificar que todo esté funcionando correctamente
class FirestoreVerificationWidget extends StatelessWidget {
  const FirestoreVerificationWidget({super.key});

  Future<void> _verifySetup() async {
    print('=== INICIANDO VERIFICACIÓN ===');
    
    // 1. Verificar usuario actual
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ ERROR: No hay usuario autenticado');
      return;
    }
    
    print('✅ Usuario autenticado: ${user.uid}');
    print('   Email: ${user.email}');
    
    try {
      // 2. Verificar datos del usuario
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        print('❌ ERROR: No se encontraron datos del usuario');
        return;
      }
      
      final userData = userDoc.data()!;
      print('✅ Datos del usuario encontrados:');
      print('   Nombre: ${userData['name']}');
      print('   Rol: ${userData['role']}');
      print('   Company ID: ${userData['companyId']}');
      
      // 3. Verificar empresa
      final companyId = userData['companyId'];
      if (companyId == null) {
        print('❌ ERROR: Usuario sin empresa asignada');
        return;
      }
      
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();
      
      if (!companyDoc.exists) {
        print('❌ ERROR: No se encontró la empresa');
        return;
      }
      
      final companyData = companyDoc.data()!;
      print('✅ Empresa encontrada:');
      print('   Nombre: ${companyData['name']}');
      print('   Código: ${companyData['code']}');
      
      // 4. VERIFICAR CAMPOS CRÍTICOS
      if (!companyData.containsKey('members')) {
        print('❌ ERROR: La empresa NO tiene campo "members"');
      } else {
        print('✅ Campo "members" existe: ${companyData['members']}');
        if ((companyData['members'] as List).contains(user.uid)) {
          print('✅ Usuario está en members');
        } else {
          print('❌ ERROR: Usuario NO está en members');
        }
      }
      
      if (!companyData.containsKey('admins')) {
        print('❌ ERROR: La empresa NO tiene campo "admins"');
      } else {
        print('✅ Campo "admins" existe: ${companyData['admins']}');
        if ((companyData['admins'] as List).contains(user.uid)) {
          print('✅ Usuario es admin');
        } else {
          print('⚠️ Usuario NO es admin (normal si es empleado)');
        }
      }
      
      // 5. Intentar acceder a proveedores
      print('\n=== PROBANDO ACCESO A PROVEEDORES ===');
      try {
        final suppliersQuery = await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('suppliers')
            .limit(1)
            .get();
        
        print('✅ Acceso a proveedores EXITOSO');
        print('   Proveedores encontrados: ${suppliersQuery.docs.length}');
      } catch (e) {
        print('❌ ERROR accediendo a proveedores: $e');
      }
      
      // 6. Intentar crear un proveedor de prueba
      if (userData['role'] == 'admin') {
        print('\n=== PROBANDO CREAR PROVEEDOR (Solo Admin) ===');
        try {
          await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyId)
              .collection('suppliers')
              .add({
            'name': 'Proveedor de Prueba',
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('✅ Proveedor creado exitosamente');
        } catch (e) {
          print('❌ ERROR creando proveedor: $e');
        }
      }
      
      print('\n=== VERIFICACIÓN COMPLETADA ===');
      
    } catch (e) {
      print('❌ ERROR GENERAL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación Firestore'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verifica la consola para ver los resultados',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifySetup,
              child: const Text('Ejecutar Verificación'),
            ),
            const SizedBox(height: 40),
            const Text(
              'Revisa la consola de debug para ver:\n'
              '- Si el usuario está autenticado\n'
              '- Si tiene empresa asignada\n'
              '- Si los campos members/admins existen\n'
              '- Si puede acceder a los datos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// Para usar este widget, añádelo temporalmente en tu app:
// Navigator.push(context, MaterialPageRoute(
//   builder: (context) => const FirestoreVerificationWidget()
// ));
