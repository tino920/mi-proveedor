import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../shared/models/product_model.dart';

class ProductsCleanupWidget extends StatefulWidget {
  const ProductsCleanupWidget({super.key});

  @override
  State<ProductsCleanupWidget> createState() => _ProductsCleanupWidgetState();
}

class _ProductsCleanupWidgetState extends State<ProductsCleanupWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> cleanupResults = {};
  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cleaning_services, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                '🧹 LIMPIEZA DE PRODUCTOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange.shade700,
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
                Text('Analizando y limpiando productos...'),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _runProductsCleanup,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('🚀 LIMPIAR PRODUCTOS INVÁLIDOS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
              ),
            ),

          if (cleanupResults.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            
            Text(
              '📊 RESULTADOS DE LA LIMPIEZA:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 12),
            
            ...cleanupResults.entries.map((entry) => 
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
          ],
        ],
      ),
    );
  }

  Future<void> _runProductsCleanup() async {
    setState(() {
      isRunning = true;
      cleanupResults.clear();
    });

    try {
      final authProvider = context.read<RestauAuthProvider>();
      final companyId = authProvider.companyId;

      if (companyId == null) {
        cleanupResults['❌ ERROR'] = 'CompanyId es NULL';
        setState(() => isRunning = false);
        return;
      }

      cleanupResults['🏢 Company ID'] = companyId;

      // 1. Obtener todos los productos
      final productsSnapshot = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('products')
          .get();

      cleanupResults['📦 Total Productos'] = '${productsSnapshot.docs.length} encontrados';

      if (productsSnapshot.docs.isEmpty) {
        cleanupResults['ℹ️ INFO'] = 'No hay productos para limpiar';
        setState(() => isRunning = false);
        return;
      }

      // 2. Analizar productos con categorías inválidas
      List<Map<String, dynamic>> invalidProducts = [];
      List<Map<String, dynamic>> invalidUnits = [];

      for (final doc in productsSnapshot.docs) {
        final data = doc.data();
        final productId = doc.id;
        final category = data['category'] ?? '';
        final unit = data['unit'] ?? '';
        final name = data['name'] ?? 'Sin nombre';

        // Verificar categoría
        if (!ProductCategories.all.contains(category)) {
          invalidProducts.add({
            'id': productId,
            'name': name,
            'oldCategory': category,
            'data': data,
          });
        }

        // Verificar unidad
        if (!ProductUnits.all.contains(unit)) {
          invalidUnits.add({
            'id': productId,
            'name': name,
            'oldUnit': unit,
            'data': data,
          });
        }
      }

      cleanupResults['⚠️ Categorías Inválidas'] = '${invalidProducts.length} productos';
      cleanupResults['⚠️ Unidades Inválidas'] = '${invalidUnits.length} productos';

      if (invalidProducts.isNotEmpty) {
        cleanupResults['📋 Productos con Categorías Inválidas'] = invalidProducts
            .map((p) => '${p['name']} (${p['oldCategory']})')
            .join(', ');
      }

      if (invalidUnits.isNotEmpty) {
        cleanupResults['📋 Productos con Unidades Inválidas'] = invalidUnits
            .map((p) => '${p['name']} (${p['oldUnit']})')
            .join(', ');
      }

      // 3. Limpiar productos con categorías inválidas
      if (invalidProducts.isNotEmpty) {
        final batch = _firestore.batch();
        int fixedCategories = 0;

        for (final product in invalidProducts) {
          try {
            final productRef = _firestore
                .collection('companies')
                .doc(companyId)
                .collection('products')
                .doc(product['id']);

            // Asignar categoría "Otros" por defecto
            batch.update(productRef, {
              'category': 'Otros',
              'oldCategory': product['oldCategory'], // Guardar la categoría original
              'fixedAt': Timestamp.now(),
            });

            fixedCategories++;
            debugPrint('✅ FIXING: ${product['name']} (${product['oldCategory']} → Otros)');
          } catch (e) {
            debugPrint('❌ ERROR fixing ${product['id']}: $e');
          }
        }

        await batch.commit();
        cleanupResults['✅ Categorías Corregidas'] = '$fixedCategories productos → "Otros"';
      }

      // 4. Limpiar productos con unidades inválidas
      if (invalidUnits.isNotEmpty) {
        final batch = _firestore.batch();
        int fixedUnits = 0;

        for (final product in invalidUnits) {
          try {
            final productRef = _firestore
                .collection('companies')
                .doc(companyId)
                .collection('products')
                .doc(product['id']);

            // Asignar unidad "unidad" por defecto
            batch.update(productRef, {
              'unit': 'unidad',
              'oldUnit': product['oldUnit'], // Guardar la unidad original
              'fixedAt': Timestamp.now(),
            });

            fixedUnits++;
            debugPrint('✅ FIXING: ${product['name']} (${product['oldUnit']} → unidad)');
          } catch (e) {
            debugPrint('❌ ERROR fixing ${product['id']}: $e');
          }
        }

        await batch.commit();
        cleanupResults['✅ Unidades Corregidas'] = '$fixedUnits productos → "unidad"';
      }

      // 5. Resumen final
      if (invalidProducts.isEmpty && invalidUnits.isEmpty) {
        cleanupResults['🎉 RESULTADO'] = 'Todos los productos están correctos';
      } else {
        cleanupResults['🎉 RESULTADO'] = 'Limpieza completada exitosamente';
      }

      // Mostrar notificación de éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Limpieza completada: ${invalidProducts.length + invalidUnits.length} productos corregidos'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      cleanupResults['❌ ERROR GENERAL'] = e.toString();
      debugPrint('❌ ERROR en limpieza de productos: $e');
    }

    setState(() => isRunning = false);
  }
}
