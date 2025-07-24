import 'package:flutter/material.dart';
import '../shared/models/product_model.dart';
import '../features/products/providers/products_provider.dart';

// Archivo de prueba para verificar que las clases funcionan correctamente
class TestProducts {
  static void testProductCategories() {
    print('Testing ProductCategories...');
    print('All categories: ${ProductCategories.all}');
    print('First category: ${ProductCategories.all.isNotEmpty ? ProductCategories.all[0] : "EMPTY"}');
    print('Icon for Carnes: ${ProductCategories.getIcon("Carnes")}');
    print('Icon for Otros: ${ProductCategories.getIcon("Otros")}');
  }

  static void testProductUnits() {
    print('Testing ProductUnits...');
    print('All units: ${ProductUnits.all}');
    print('First unit: ${ProductUnits.all.isNotEmpty ? ProductUnits.all[0] : "EMPTY"}');
  }

  static void testProduct() {
    print('Testing Product creation...');
    try {
      final product = Product(
        id: 'test_001',
        name: 'Producto de Prueba',
        category: 'Otros',
        price: 10.50,
        unit: 'unidad',
        supplierId: 'supplier_001',
        description: 'Descripción de prueba',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      print('Product created successfully:');
      print('- ID: ${product.id}');
      print('- Name: ${product.name}');
      print('- Category: ${product.category}');
      print('- Price: ${product.formattedPrice}');
      print('- Price with unit: ${product.priceWithUnit}');
      print('- Initials: ${product.initials}');
      
      // Test conversion
      final map = product.toMap();
      print('- ToMap successful: ${map.isNotEmpty}');
      
    } catch (e) {
      print('ERROR creating product: $e');
    }
  }

  static void testProductsProvider() {
    print('Testing ProductsProvider...');
    try {
      final provider = ProductsProvider();
      print('ProductsProvider created successfully');
      print('- Is loading: ${provider.isLoading}');
      print('- Error: ${provider.error}');
      print('- Products count: ${provider.products.length}');
    } catch (e) {
      print('ERROR creating ProductsProvider: $e');
    }
  }

  static void runAllTests() {
    print('=== STARTING PRODUCT TESTS ===');
    testProductCategories();
    print('');
    testProductUnits();
    print('');
    testProduct();
    print('');
    testProductsProvider();
    print('=== TESTS COMPLETED ===');
  }
}
