import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String supplierId;
  final String? description;
  final String? imageUrl;
  final String? sku;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? importBatch; // Para identificar productos importados desde Excel
  
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.supplierId,
    this.description,
    this.imageUrl,
    this.sku,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.importBatch,
  });



  // Crear desde Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      supplierId: data['supplierId'] ?? '',
      description: data['description'],
      imageUrl: data['imageUrl'],
      sku: data['sku'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      importBatch: data['importBatch'],
    );
  }

  // Crear desde Map (para import Excel)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      supplierId: map['supplierId'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      sku: map['sku'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] ?? DateTime.now(),
      updatedAt: map['updatedAt'] ?? DateTime.now(),
      importBatch: map['importBatch'],
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'supplierId': supplierId,
      'description': description,
      'imageUrl': imageUrl,
      'sku': sku,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'importBatch': importBatch,
    };
  }

  // Crear copia con cambios
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? unit,
    String? supplierId,
    String? description,
    String? imageUrl,
    String? sku,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? importBatch,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      supplierId: supplierId ?? this.supplierId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      sku: sku ?? this.sku,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      importBatch: importBatch ?? this.importBatch,
    );
  }

  // Formatear precio
  String get formattedPrice => '€${price.toStringAsFixed(2)}';
  
  // Formatear precio con unidad
  String get priceWithUnit => '€${price.toStringAsFixed(2)}/$unit';
  
  // Obtener iniciales para avatar si no hay imagen
  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].length >= 2 
        ? words[0].substring(0, 2).toUpperCase()
        : words[0].toUpperCase();
    }
    return 'PR';
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, price: $price, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Categorías predefinidas para productos
class ProductCategories {
  static const List<String> all = [
    'Carnes',
    'Pescados y Mariscos',
    'Verduras y Hortalizas',
    'Pasta',
    'Frutas',
    'Lácteos',
    'Panadería',
    'Postres',
    'Bebidas',
    'Condimentos y Especias',
    'Salsas',
    'Conservas',
    'Congelados',
    'Aceites y Vinagres',
    'Legumbres y Cereales',
    'Frutto Secos',
    'Limpieza e Higiene',
    'Otros',
  ];

  static const Map<String, String> icons = {
    'Carnes': '🥩',
    'Pescados y Mariscos': '🐟',
    'Verduras y Hortalizas': '🥬',
    'Pasta': '🍝',
    'Frutas': '🍎',
    'Lácteos': '🥛',
    'Panadería': '🍞',
    'Postres':'🍨',
    'Bebidas': '🥤',
    'Condimentos y Especias': '🌶️',
    'Salsas': '🫙',
    'Conservas': '🥫',
    'Congelados': '🧊',
    'Aceites y Vinagres': '🫒',
    'Legumbres y Cereales': '🌾',
    'Frutto Secos':'🥜',
    'Limpieza e Higiene': '🧽',  // 🧽 AÑADIDA
    'Otros': '📦',
  };

  static String getIcon(String category) {
    return icons[category] ?? '📦';
  }
}

// Unidades predefinidas
class ProductUnits {
  static const List<String> all = [
    'kg',
    'g',
    'l',
    'ml',
    'unidad',
    'pieza',
    'docena',
    'caja',
    'pack',
    'botella',
    'lata',
    'sobre',
    'bandeja',
    'spray',      // 🧽 Para productos de limpieza
    'bote',       // 🧽 Para productos de limpieza
    'frasco',     // 🧽 Para productos de limpieza
    'rollo',      // 🧽 Para papel, etc.
    'tubo',       // 🧽 Para pasta, cremas, etc.
  ];
}
