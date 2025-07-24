

class OrderItem {
  final String productId;
  final String productName;
  final String category;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final String? notes;
  final String? imageUrl;
  final String? description;
  
  OrderItem({
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
    this.imageUrl,
    this.description,
  });

  factory OrderItem.fromProduct({
    required String productId,
    required String productName,
    required String category,
    required double quantity,
    required String unit,
    required double unitPrice,
    String? notes,
    String? imageUrl,
    String? description,
  }) {
    return OrderItem(
      productId: productId,
      productName: productName,
      category: category,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      totalPrice: quantity * unitPrice,
      notes: notes,
      imageUrl: imageUrl,
      description: description,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      category: map['category'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      notes: map['notes'],
      imageUrl: map['imageUrl'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'notes': notes,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? category,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalPrice,
    String? notes,
    String? imageUrl,
    String? description,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? (quantity ?? this.quantity) * (unitPrice ?? this.unitPrice),
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  // Helper methods
  String get quantityText => '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)} $unit';
  String get unitPriceText => '€${unitPrice.toStringAsFixed(2)}/$unit';
  String get totalPriceText => '€${totalPrice.toStringAsFixed(2)}';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is OrderItem && other.productId == productId;
  }
  
  @override
  int get hashCode => productId.hashCode;
}
