import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../../shared/models/order_model.dart';
import '../../../shared/models/order_item_model.dart';
import '../../../shared/models/product_model.dart';

class OrdersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Mapa para guardar los borradores de pedidos por ID de proveedor
  final Map<String, Order> _draftOrders = {};

  Order? _currentOrder;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  Order? get currentOrder => _currentOrder;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  List<Order> get allOrders => _orders;
  String? get error => _error;

  Map<String, OrderItem> get cartItems => { for (var item in _currentOrder?.items ?? []) item.productId : item };
  double get cartTotal => _currentOrder?.total ?? 0.0;
  int get cartItemCount => _currentOrder?.items.length ?? 0;

  List<Order> get pendingOrders => _orders.where((order) => order.status == OrderStatus.pending).toList();
  List<Order> get approvedOrders => _orders.where((order) => order.status == OrderStatus.approved).toList();
  List<Order> get sentOrders => _orders.where((order) => order.status == OrderStatus.sent).toList();
  List<Order> get rejectedOrders => _orders.where((order) => order.status == OrderStatus.rejected).toList();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // ✅ Lógica actualizada para manejar borradores
  Future<Order?> createDraftOrder({
    required String companyId,
    required String employeeId,
    required String employeeName,
    required String supplierId,
    required String supplierName,
  }) async {
    _setLoading(true);

    // Si ya existe un borrador para este proveedor, lo cargamos
    if (_draftOrders.containsKey(supplierId)) {
      _currentOrder = _draftOrders[supplierId];
      _setLoading(false);
      notifyListeners();
      return _currentOrder;
    }

    // Si no, creamos uno nuevo
    _currentOrder = Order(
      id: '',
      orderNumber: Order.generateOrderNumber(),
      companyId: companyId,
      employeeId: employeeId,
      employeeName: employeeName,
      supplierId: supplierId,
      supplierName: supplierName,
      status: OrderStatus.draft,
      items: [],
      subtotal: 0,
      tax: 0,
      total: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Guardamos el nuevo borrador en el mapa
    _draftOrders[supplierId] = _currentOrder!;

    _setLoading(false);
    notifyListeners();
    return _currentOrder;
  }

  // ✅ Pequeña función para guardar el estado del borrador actual
  void _saveCurrentDraft() {
    if (_currentOrder != null) {
      _draftOrders[_currentOrder!.supplierId] = _currentOrder!;
    }
  }

  Future<bool> addProductToOrder({
    required Product product,
    required double quantity,
    String? notes,
  }) async {
    if (_currentOrder == null) return false;

    final newItem = OrderItem.fromProduct(
      productId: product.id,
      productName: product.name,
      category: product.category,
      quantity: quantity,
      unit: product.unit,
      unitPrice: product.price,
      notes: notes,
      imageUrl: product.imageUrl,
      description: product.description,
    );

    final existingIndex = _currentOrder!.items.indexWhere((item) => item.productId == newItem.productId);

    if (existingIndex != -1) {
      final existingItem = _currentOrder!.items[existingIndex];
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + quantity);
      _currentOrder!.items[existingIndex] = updatedItem;
    } else {
      _currentOrder!.items.add(newItem);
    }

    _recalculateTotals();
    _saveCurrentDraft(); // Guardamos el borrador después de añadir un producto
    notifyListeners();
    return true;
  }

  void updateQuantity(String productId, double newQuantity) {
    if (_currentOrder == null) return;
    final index = _currentOrder!.items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (newQuantity > 0) {
        _currentOrder!.items[index] = _currentOrder!.items[index].copyWith(quantity: newQuantity);
      } else {
        _currentOrder!.items.removeAt(index);
      }
      _recalculateTotals();
      _saveCurrentDraft(); // Guardamos el borrador
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    if (_currentOrder == null) return;
    _currentOrder!.items.removeWhere((item) => item.productId == productId);
    _recalculateTotals();
    _saveCurrentDraft(); // Guardamos el borrador
    notifyListeners();
  }

  void updateProductQuantity(String productId, double newQuantity) {
    updateQuantity(productId, newQuantity);
  }

  void removeProductFromOrder(String productId) {
    removeFromCart(productId);
  }

  // ✅ Lógica actualizada para limpiar el borrador
  void clearCart() {
    if (_currentOrder != null) {
      _draftOrders.remove(_currentOrder!.supplierId);
      _currentOrder = null;
    }
    notifyListeners();
  }

  void _recalculateTotals() {
    if (_currentOrder == null) return;
    double subtotal = 0;
    for (var item in _currentOrder!.items) {
      subtotal += item.totalPrice;
    }
    double tax = 0;
    double total = subtotal + tax;
    _currentOrder = _currentOrder!.copyWith(subtotal: subtotal, tax: tax, total: total);
  }

  Future<bool> submitOrderForApproval({
    String? notes,
    required bool isAdmin,
    String? adminName,
  }) async {
    if (_currentOrder == null || _currentOrder!.items.isEmpty) {
      _setError('El pedido está vacío.');
      return false;
    }

    _setLoading(true);
    try {
      OrderStatus finalStatus;
      Map<String, dynamic> additionalFields = {};

      if (isAdmin) {
        finalStatus = OrderStatus.approved;
        additionalFields = {
          'approvedBy': _currentOrder!.employeeId,
          'approvedByName': adminName ?? _currentOrder!.employeeName,
          'approvedAt': FieldValue.serverTimestamp(),
          'adminNotes': 'Auto-aprobado (pedido de administrador)',
        };
      } else {
        finalStatus = OrderStatus.pending;
      }

      final orderToSave = _currentOrder!.copyWith(
        notes: notes,
        status: finalStatus,
        updatedAt: DateTime.now(),
      );

      final firestoreData = orderToSave.toFirestore();
      firestoreData.addAll(additionalFields);

      await _firestore
          .collection('companies')
          .doc(orderToSave.companyId)
          .collection('orders')
          .add(firestoreData);

      // ✅ Eliminamos el borrador después de enviarlo
      if (_currentOrder != null) {
        _draftOrders.remove(_currentOrder!.supplierId);
      }
      _currentOrder = null;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Stream<List<Order>> getOrdersStream(String companyId) {
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      _orders = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
      notifyListeners();
      return _orders;
    });
  }

  Stream<List<Order>> getOrdersStreamForAdmin(String companyId) {
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      _orders = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
      notifyListeners();
      return _orders;
    });
  }

  Future<bool> approveOrder({
    required String companyId,
    required String orderId,
    required String adminId,
    required String adminName,
    String? notes,
  }) async {
    try {
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': OrderStatus.approved.name,
        'approvedBy': adminId,
        'approvedByName': adminName,
        'approvedAt': FieldValue.serverTimestamp(),
        'adminNotes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> rejectOrder({
    required String companyId,
    required String orderId,
    required String adminId,
    required String adminName,
    required String reason,
  }) async {
    try {
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': OrderStatus.rejected.name,
        'rejectedBy': adminId,
        'rejectedByName': adminName,
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> sendOrderToSupplier({
    required String companyId,
    required String orderId,
    required String method,
  }) async {
    try {
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': OrderStatus.sent.name,
        'sentAt': FieldValue.serverTimestamp(),
        'sentMethod': method,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> markNotificationsAsViewed(String companyId, String employeeId) async {
    final querySnapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('orders')
        .where('employeeId', isEqualTo: employeeId)
        .where('status', whereIn: ['approved', 'rejected'])
        .where('viewedByEmployee', isEqualTo: false)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'viewedByEmployee': true});
    }

    await batch.commit();
  }

  Future<Map<String, dynamic>> deleteOrder({
    required String companyId,
    required String orderId,
  }) async {
    try {
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('orders')
          .doc(orderId)
          .delete();
      return {'success': true};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  // 📝 NUEVO: CARGAR PEDIDO PARA EDICIÓN
  void loadOrderForEditing(Order order) {
    _currentOrder = order.copyWith();
    _saveCurrentDraft();
    notifyListeners();
  }

  /// ✅ NUEVO: Guarda los cambios de un pedido existente en Firestore.

  Future<bool> updateExistingOrder({
    required String companyId, // <-- AÑADIDO: Se requiere el companyId
    required Order order,
    String? notes,
  }) async {
    if (_currentOrder == null) return false;

    _setLoading(true);
    try {
      final orderToUpdate = _currentOrder!.copyWith(
        notes: notes,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('companies')
          .doc(companyId) // <-- USAMOS el companyId que pasamos como parámetro
          .collection('orders')
          .doc(order.id)
          .update(orderToUpdate.toFirestore());

      // Limpiar el borrador después de actualizar
      if (_currentOrder != null) {
        _draftOrders.remove(_currentOrder!.supplierId);
      }
      _currentOrder = null;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
}
