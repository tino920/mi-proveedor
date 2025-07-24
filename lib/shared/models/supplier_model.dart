import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  final String id;
  final String name;
  final String? description;
  final String? email;
  final String? phone;
  final String? address;
  final String? imageUrl;
  final List<String> deliveryDays;
  final String companyId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? type; // 🆕 NUEVO: 'alimentacion', 'bebidas', 'limpieza', 'mixto', 'otros'
  
  Supplier({
    required this.id,
    required this.name,
    this.description,
    this.email,
    this.phone,
    this.address,
    this.imageUrl,
    required this.deliveryDays,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.type, // 🆕 NUEVO CAMPO
  });
  
  factory Supplier.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Supplier(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      email: data['email'],
      phone: data['phone'],
      address: data['address'],
      imageUrl: data['imageUrl'],
      deliveryDays: List<String>.from(data['deliveryDays'] ?? []),
      companyId: data['companyId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'], // 🆕 NUEVO CAMPO
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'email': email,
      'phone': phone,
      'address': address,
      'imageUrl': imageUrl,
      'deliveryDays': deliveryDays,
      'companyId': companyId,
      'type': type, // 🆕 NUEVO CAMPO
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  Supplier copyWith({
    String? id,
    String? name,
    String? description,
    String? email,
    String? phone,
    String? address,
    String? imageUrl,
    List<String>? deliveryDays,
    String? companyId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type, // 🆕 NUEVO CAMPO
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      deliveryDays: deliveryDays ?? this.deliveryDays,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type, // 🆕 NUEVO CAMPO
    );
  }
}

// 🆕 NUEVA CLASE: Utilidades para tipos de proveedores
class SupplierTypeUtils {
  // Definición de grupos de categorías
  static const Map<String, List<String>> categoryGroups = {
    'alimentacion': [
      'Carnes',
      'Pescados y Mariscos', 
      'Verduras y Hortalizas',
      'Pasta',
      'Frutas',
      'Lácteos',
      'Panadería',
      'Postres',
      'Condimentos y Especias',
      'Salsas',
      'Conservas', 
      'Congelados',
      'Aceites y Vinagres',
      'Legumbres y Cereales',
      'Frutto Secos',


    ],
    'bebidas': [
      'Bebidas',
      'Refresco',
      'Vino',
      'alcohol',
    ],
    'limpieza': ['Limpieza e Higiene'],
    'otros': ['Otros'],
  };

  // Iconos para cada tipo
  static const Map<String, String> typeIcons = {
    'alimentacion': '🍽️',
    'bebidas': '🥤',
    'limpieza': '🧽',
    'mixto': '🔄',
    'otros': '📦',
  };

  // Nombres display para cada tipo
  static const Map<String, String> typeNames = {
    'alimentacion': 'Alimentación',
    'bebidas': 'Bebidas',
    'limpieza': 'Limpieza e Higiene',
    'mixto': 'Mixto (Varios tipos)',
    'otros': 'Otros',
  };

  // 🔍 Detectar tipo de proveedor basado en productos
  static String detectProviderTypeFromProducts(List<String> productCategories) {
    if (productCategories.isEmpty) return 'otros';
    
    Set<String> categories = productCategories.toSet();
    
    bool hasAlimentacion = categories.any((cat) => 
        categoryGroups['alimentacion']!.contains(cat));
    bool hasBebidas = categories.any((cat) => 
        categoryGroups['bebidas']!.contains(cat));
    bool hasLimpieza = categories.any((cat) => 
        categoryGroups['limpieza']!.contains(cat));
    bool hasOtros = categories.any((cat) => 
        categoryGroups['otros']!.contains(cat));
    
    // Contar cuántos tipos diferentes tiene
    int typeCount = 0;
    if (hasAlimentacion) typeCount++;
    if (hasBebidas) typeCount++;
    if (hasLimpieza) typeCount++;
    if (hasOtros) typeCount++;
    
    // Si tiene más de un tipo, es mixto
    if (typeCount > 1) return 'mixto';
    
    // Si tiene solo un tipo, retornar ese tipo
    if (hasAlimentacion) return 'alimentacion';
    if (hasBebidas) return 'bebidas';
    if (hasLimpieza) return 'limpieza';
    return 'otros';
  }

  // 🤔 Determinar tipo final (híbrido)
  static String getProviderType(Supplier supplier, List<String> productCategories) {
    // 1. Si hay productos, usar detección automática (más precisa)
    if (productCategories.isNotEmpty) {
      return detectProviderTypeFromProducts(productCategories);
    }
    
    // 2. Si no hay productos, usar el tipo configurado
    return supplier.type ?? 'mixto';
  }

  // 📊 Obtener categorías relevantes para filtros
  static List<String> getRelevantCategories(String providerType, List<String> actualCategories) {
    switch (providerType) {
      case 'alimentacion':
        return actualCategories.where((cat) => 
            categoryGroups['alimentacion']!.contains(cat)).toList();
      case 'bebidas':
        return actualCategories.where((cat) => 
            categoryGroups['bebidas']!.contains(cat)).toList();
      case 'limpieza':
        return actualCategories.where((cat) => 
            categoryGroups['limpieza']!.contains(cat)).toList();
      case 'mixto':
      default:
        return actualCategories;
    }
  }

  // 🎨 Obtener icono para tipo
  static String getTypeIcon(String type) {
    return typeIcons[type] ?? '📦';
  }

  // 🏷️ Obtener nombre display para tipo
  static String getTypeName(String type) {
    return typeNames[type] ?? 'Otros';
  }

  // 📝 Lista de todos los tipos disponibles
  static List<String> get allTypes => ['alimentacion', 'bebidas', 'limpieza', 'mixto', 'otros'];
}
