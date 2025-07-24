import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/products/providers/products_provider.dart';
import '../shared/models/product_model.dart';
import 'test_products.dart';

class TestProductsScreen extends StatefulWidget {
  const TestProductsScreen({super.key});

  @override
  State<TestProductsScreen> createState() => _TestProductsScreenState();
}

class _TestProductsScreenState extends State<TestProductsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedCategory = 'Otros';
  String _selectedUnit = 'unidad';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              TestProducts.runAllTests();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tests ejecutados - Ver console')),
              );
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (_) => ProductsProvider(),
        child: Consumer<ProductsProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prueba de Productos',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Información de categorías
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Categorías disponibles:', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ProductCategories.all.map((category) {
                              return Chip(
                                label: Text('${ProductCategories.getIcon(category)} $category'),
                                backgroundColor: _selectedCategory == category 
                                  ? Colors.blue.shade100 
                                  : null,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Formulario de prueba
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Crear Producto de Prueba:', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del producto',
                              hintText: 'Ej: Salmón de prueba',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: const InputDecoration(
                                    labelText: 'Categoría',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: ProductCategories.all.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text('${ProductCategories.getIcon(category)} $category'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedUnit,
                                  decoration: const InputDecoration(
                                    labelText: 'Unidad',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: ProductUnits.all.map((unit) {
                                    return DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUnit = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                              hintText: '10.50',
                              prefixText: '€ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _testCreateProduct,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                              child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Crear Producto de Prueba'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Estado del provider
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estado del Provider:', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Loading: ${provider.isLoading}'),
                          Text('Error: ${provider.error ?? "Ninguno"}'),
                          Text('Productos cargados: ${provider.products.length}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _testCreateProduct() async {
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Precio inválido')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ProductsProvider>(context, listen: false);
      
      // NOTA: Para esta prueba usamos IDs ficticios
      final result = await provider.createProduct(
        companyId: 'test_company_001', // ID ficticio para prueba
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: price,
        unit: _selectedUnit,
        supplierId: 'test_supplier_001', // ID ficticio para prueba
        description: 'Producto de prueba creado desde test screen',
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto creado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Limpiar formulario
        _nameController.clear();
        _priceController.clear();
        setState(() {
          _selectedCategory = 'Otros';
          _selectedUnit = 'unidad';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
