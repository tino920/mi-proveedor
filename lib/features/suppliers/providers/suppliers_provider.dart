import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/models/supplier_model.dart';

class SuppliersProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<Supplier>> getSuppliersStream(String companyId) {
    try {
      return _firestore
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .snapshots()
          .map((snapshot) {
        final suppliers = snapshot.docs.map((doc) => Supplier.fromFirestore(doc)).toList();
        suppliers.sort((a, b) => a.name.compareTo(b.name));
        _suppliers = suppliers;
        return suppliers;
      }).handleError((error) {
        _setError('Error al cargar proveedores: $error');
        return <Supplier>[];
      });
    } catch (e) {
      _setError('Error creando stream: $e');
      return Stream.value(<Supplier>[]);
    }
  }

  Future<Map<String, dynamic>> createSupplier({
    required String companyId,
    required String name,
    String? description,
    String? email,
    String? phone,
    String? address,
    List<String>? deliveryDays,
    File? imageFile,
    String? type, // 🆕 NUEVO CAMPO
  }) async {
    _setLoading(true);
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, companyId);
      }

      final supplier = Supplier(
        id: '',
        name: name,
        description: description,
        email: email,
        phone: phone,
        address: address,
        imageUrl: imageUrl,
        deliveryDays: deliveryDays ?? [],
        companyId: companyId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: type, // 🆕 NUEVO CAMPO
      );

      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .add(supplier.toFirestore());

      _setLoading(false);
      return {'success': true};
    } catch (e) {
      _setError('Error al crear proveedor: $e');
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateSupplier({
    required String companyId,
    required String supplierId,
    required String name,
    String? description,
    String? email,
    String? phone,
    String? address,
    List<String>? deliveryDays,
    File? imageFile,
    String? existingImageUrl,
    String? type, // 🆕 NUEVO CAMPO
  }) async {
    _setLoading(true);
    try {
      String? imageUrl = existingImageUrl;
      if (imageFile != null) {
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await _deleteImage(existingImageUrl);
        }
        imageUrl = await _uploadImage(imageFile, companyId);
      }

      final updateData = {
        'name': name,
        'description': description,
        'email': email,
        'phone': phone,
        'address': address,
        'imageUrl': imageUrl,
        'deliveryDays': deliveryDays ?? [],
        'type': type, // 🆕 NUEVO CAMPO
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .doc(supplierId)
          .update(updateData);

      _setLoading(false);
      return {'success': true};
    } catch (e) {
      _setError('Error al actualizar proveedor: $e');
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  // --- MÉTODO DE BORRADO ACTUALIZADO ---
  Future<Map<String, dynamic>> deleteSupplier({
    required String companyId,
    required String supplierId,
    String? imageUrl,
  }) async {
    _setLoading(true);
    try {
      // 1. Eliminar imagen de Storage si existe
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _deleteImage(imageUrl);
      }

      // 2. Eliminar el documento del proveedor en Firestore.
      // La Cloud Function 'onDeleteSupplierCleanup' se activará automáticamente
      // y se encargará de borrar los productos asociados.
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('suppliers')
          .doc(supplierId)
          .delete();

      _setLoading(false);
      return {'success': true};
    } catch (e) {
      _setError('Error al eliminar proveedor: $e');
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<File?> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      _setError('Error al seleccionar imagen: $e');
      return null;
    }
  }

  Future<String> _uploadImage(File imageFile, String companyId) async {
    final fileName = 'supplier_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('companies/$companyId/suppliers/$fileName');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      // Ignoramos el error si el archivo no existe, puede pasar.
      debugPrint('Info: No se pudo eliminar la imagen (puede que ya no exista): $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
