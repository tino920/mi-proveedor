// lib/features/products/providers/products_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../shared/models/product_model.dart';

class ProductsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  String? _error;
  List<Product> _products = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get products => _products;

  Stream<List<Product>> getProductsStream(String companyId, String supplierId) {
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('products')
        .where('supplierId', isEqualTo: supplierId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs.map((doc) {
        try {
          return Product.fromFirestore(doc);
        } catch (e) {
          print('Error parsing product ${doc.id}: $e');
          return null;
        }
      }).where((product) => product != null).cast<Product>().toList();
      _products = products;
      return products;
    });
  }

  Future<Map<String, dynamic>> createProduct({
    required String companyId,
    required String name,
    required String category,
    required double price,
    required String unit,
    required String supplierId,
    String? description,
    String? sku,
    File? imageFile,
  }) async {
    _setLoading(true);
    try {
      final productId = _firestore.collection('companies').doc(companyId).collection('products').doc().id;
      String? imageUrl;
      if (imageFile != null) {
        final uploadResult = await _uploadProductImage(companyId: companyId, productId: productId, imageFile: imageFile);
        if (uploadResult['success']) imageUrl = uploadResult['imageUrl'];
      }

      final product = Product(
        id: productId,
        name: name.trim(),
        category: category,
        price: price,
        unit: unit,
        supplierId: supplierId,
        description: description?.trim(),
        imageUrl: imageUrl,
        sku: sku?.trim(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('companies').doc(companyId).collection('products').doc(productId).set(product.toMap());
      _setLoading(false);
      return {'success': true, 'productId': productId};
    } catch (e) {
      _setError('Error creando producto: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProduct({
    required String companyId,
    required String productId,
    required String name,
    required String category,
    required double price,
    required String unit,
    String? description,
    String? sku,
    File? imageFile,
    String? currentImageUrl,
  }) async {
    _setLoading(true);
    try {
      String? imageUrl = currentImageUrl;
      if (imageFile != null) {
        if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
          await _deleteProductImage(currentImageUrl);
        }
        final uploadResult = await _uploadProductImage(companyId: companyId, productId: productId, imageFile: imageFile);
        if (uploadResult['success']) imageUrl = uploadResult['imageUrl'];
      }

      final updateData = {
        'name': name.trim(), 'category': category, 'price': price, 'unit': unit,
        'description': description?.trim(), 'sku': sku?.trim(), 'imageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('companies').doc(companyId).collection('products').doc(productId).update(updateData);
      _setLoading(false);
      return {'success': true};
    } catch (e) {
      _setError('Error actualizando producto: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  // --- MÉTODO DE BORRADO CORREGIDO ---
  Future<Map<String, dynamic>> deleteProduct({
    required String companyId,
    required String productId,
    String? imageUrl,
  }) async {
    _setLoading(true);
    try {
      // 1. Borrar la imagen del producto en Storage (si la tiene)
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _deleteProductImage(imageUrl);
      }

      // 2. Borrar el documento del producto de forma permanente
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('products')
          .doc(productId)
          .delete(); // <-- CAMBIO CLAVE: de update() a delete()

      _setLoading(false);
      return {'success': true};
    } catch (e) {
      _setError('Error al eliminar producto: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> importProductsFromExcel({
    required String companyId,
    required String supplierId,
    required List<Map<String, dynamic>> productsData,
  }) async {
    _setLoading(true);
    try {
      final batch = _firestore.batch();
      final importBatchId = 'import_${DateTime.now().millisecondsSinceEpoch}';
      int successCount = 0;
      List<String> errors = [];

      for (int i = 0; i < productsData.length; i++) {
        final productData = productsData[i];
        try {
          final name = productData['name']?.toString().trim();
          final price = double.tryParse(productData['price']?.toString().replaceAll(',', '.') ?? '');

          if (name == null || name.isEmpty) {
            errors.add('Fila ${i + 2}: El nombre es obligatorio.');
            continue;
          }
          if (price == null || price <= 0) {
            errors.add('Fila ${i + 2}: El precio es inválido.');
            continue;
          }

          final productId = _firestore.collection('companies').doc(companyId).collection('products').doc().id;

          final product = Product(
            id: productId,
            name: name,
            category: productData['category']?.toString().trim() ?? 'Otros',
            price: price,
            unit: productData['unit']?.toString().trim() ?? 'unidad',
            supplierId: supplierId,
            description: productData['description']?.toString().trim(),
            sku: productData['sku']?.toString().trim(),
            imageUrl: null,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            importBatch: importBatchId,
          );

          batch.set(
            _firestore.collection('companies').doc(companyId).collection('products').doc(productId),
            product.toMap(),
          );

          successCount++;
        } catch (e) {
          errors.add('Fila ${i + 2}: Error inesperado - ${e.toString()}');
        }
      }

      if (successCount > 0) {
        await batch.commit();
      }

      _setLoading(false);
      return {
        'success': true,
        'successCount': successCount,
        'totalRows': productsData.length,
        'errors': errors,
      };
    } catch (e) {
      _setError('Error importando productos: ${e.toString()}');
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _uploadProductImage({required String companyId, required String productId, required File imageFile}) async {
    try {
      final ref = _storage.ref().child('companies/$companyId/products/$productId/image.jpg');
      final uploadTask = ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return {'success': true, 'imageUrl': downloadUrl};
    } catch (e) {
      return {'success': false, 'error': 'Error al subir imagen: $e'};
    }
  }

  Future<void> _deleteProductImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      print('Info: No se pudo eliminar imagen (puede que no exista): $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
