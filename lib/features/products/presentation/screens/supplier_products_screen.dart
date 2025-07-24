import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/models/supplier_model.dart'; // 🆕 Contiene SupplierTypeUtils
import '../../../../shared/models/product_model.dart';
import '../../providers/products_provider.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/import_products_dialog.dart';

class SupplierProductsScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierProductsScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<SupplierProductsScreen> createState() => _SupplierProductsScreenState();
}

class _SupplierProductsScreenState extends State<SupplierProductsScreen> {
  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Product>>? _productsStream;
  List<String> _availableCategories = []; // 🆕 NUEVO: Categorías dinámicas
  
  // SOLUCIÓN: Definir categorías directamente para evitar problemas de importación
  static const List<String> _categories = [
    'Carnes',
    'Pescados y Mariscos',
    'Verduras y Hortalizas',
    'Frutas',
    'Lácteos',
    'Panadería',
    'Bebidas',
    'Condimentos y Especias',
    'Conservas',
    'Congelados',
    'Aceites y Vinagres',
    'Legumbres y Cereales',
    'Limpieza e Higiene',  // 🧽 AÑADIDA
    'Otros',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<RestauAuthProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final companyId = authProvider.companyId;

    if (companyId != null && _productsStream == null) {
      _productsStream = productsProvider.getProductsStream(companyId, widget.supplier.id);
      
      // 🆕 NUEVO: Escuchar cambios en productos para actualizar filtros
      _productsStream?.listen((products) {
        _updateAvailableCategories(products);
      });
    }
  }

  // 🆕 NUEVO: Actualizar categorías disponibles basado en productos del proveedor
  void _updateAvailableCategories(List<Product> products) {
    if (!mounted) return;
    
    // Obtener categorías reales de los productos
    final productCategories = products.map((p) => p.category).toSet().toList();
    
    // Detectar tipo de proveedor
    final providerType = SupplierTypeUtils.getProviderType(widget.supplier, productCategories);
    
    // Obtener categorías relevantes para este tipo de proveedor
    final relevantCategories = SupplierTypeUtils.getRelevantCategories(providerType, productCategories);
    
    setState(() {
      _availableCategories = relevantCategories;
      // Si la categoría seleccionada ya no es relevante, resetear a 'Todas'
      if (_selectedCategory != 'Todas' && !_availableCategories.contains(_selectedCategory)) {
        _selectedCategory = 'Todas';
      }
    });
    
    debugPrint('🔍 Proveedor: ${widget.supplier.name}');
    debugPrint('📁 Tipo detectado: $providerType');
    debugPrint('📊 Categorías disponibles: $_availableCategories');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<RestauAuthProvider>();
    final companyId = authProvider.companyId;

    if (companyId == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B73FF), Color(0xFF129793)], // ← Estos colores
          ),
        ),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Text(
              'Error: No se encontró la empresa',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF129793)], // ← Estos colores
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Productos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.supplier.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (authProvider.isAdmin)
              PopupMenuButton<String>(
                icon: const Icon(Icons.upload_file_outlined, color: Colors.white),
                onSelected: (value) {
                  HapticFeedback.selectionClick();
                  if (value == 'import') {
                    _showImportDialog(context, companyId);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'import',
                    child: Row(
                      children: [
                        Icon(Icons.upload_file, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Importar desde Excel'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: [
            // Header con filtros
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Barra de búsqueda
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar productos...',
                        hintStyle: TextStyle(color: AppTheme.textColor.withOpacity(0.6)),
                        prefixIcon: Icon(
                          Icons.search, 
                          color: AppTheme.primaryColor, 
                          size: 24
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: AppTheme.textColor.withOpacity(0.6)),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filtros de categoría
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.filter_list, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Filtrar por categoría:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCategoryChip('Todas'),
                            // 🆕 NUEVO: Usar categorías dinámicas en lugar de lista fija
                            ..._availableCategories.map((category) => _buildCategoryChip(category)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contenido principal con fondo blanco redondeado
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: StreamBuilder<List<Product>>(
                  stream: _productsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppTheme.warningColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar productos',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: TextStyle(
                                  color: AppTheme.textColor.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando productos...',
                              style: TextStyle(
                                color: AppTheme.textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final products = snapshot.data ?? [];
                    final filteredProducts = _filterProducts(products);

                    if (filteredProducts.isEmpty) {
                      return _buildEmptyState(context, companyId, authProvider.isAdmin);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        HapticFeedback.lightImpact();
                        setState(() {});
                      },
                      color: AppTheme.primaryColor,
                      child: _buildProductsListWithHeaders(filteredProducts, companyId, authProvider.isAdmin),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: authProvider.isAdmin
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.buttonGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showAddProductDialog(context, companyId);
                  },
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  heroTag: 'add_product_fab',
                  child: const Icon(
                    Icons.add,
                    size: 28,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedCategory = isSelected ? 'Todas' : category;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            // SOLUCIÓN DEFINITIVA: Fondo garantizado visible
            color: isSelected 
                ? Colors.white 
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.8),
              width: isSelected ? 2.0 : 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            category,
            style: TextStyle(
              // SOLUCIÓN DEFINITIVA: Colores garantizados
              color: isSelected 
                  ? AppTheme.primaryColor 
                  : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    List<Product> filtered = products.where((product) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          (product.description?.toLowerCase().contains(query) ?? false);

      final matchesCategory = _selectedCategory == 'Todas' || product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    // 🚀 ORDENAR AUTOMÁTICAMENTE POR CATEGORÍAS
    filtered.sort((a, b) {
      // Primero ordenar por categoría
      final categoryComparison = _getCategoryOrder(a.category).compareTo(_getCategoryOrder(b.category));
      if (categoryComparison != 0) return categoryComparison;
      
      // Luego ordenar por nombre dentro de la misma categoría
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  // 📁 OBTENER ORDEN DE CATEGORÍA
  int _getCategoryOrder(String category) {
    final index = _categories.indexOf(category);
    return index == -1 ? 999 : index; // Si no está en la lista, va al final
  }

  // 🎨 CONSTRUIR LISTA CON HEADERS DE CATEGORÍA
  Widget _buildProductsListWithHeaders(List<Product> products, String companyId, bool isAdmin) {
    if (products.isEmpty) return SizedBox.shrink();
    
    // Agrupar productos por categoría
    Map<String, List<Product>> productsByCategory = {};
    for (final product in products) {
      productsByCategory.putIfAbsent(product.category, () => []).add(product);
    }
    
    // Ordenar categorías
    final sortedCategories = productsByCategory.keys.toList()
      ..sort((a, b) => _getCategoryOrder(a).compareTo(_getCategoryOrder(b)));
    
    List<Widget> widgets = [];
    
    for (final category in sortedCategories) {
      final categoryProducts = productsByCategory[category]!;
      
      // Añadir header de categoría (solo si no hay filtro de categoría específica)
      if (_selectedCategory == 'Todas') {
        widgets.add(_buildCategoryHeader(category, categoryProducts.length));
      }
      
      // Añadir productos de la categoría
      for (final product in categoryProducts) {
        widgets.add(_ProductCard(
          product: product,
          supplier: widget.supplier,
          companyId: companyId,
          isAdmin: isAdmin,
        ));
      }
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: widgets,
    );
  }
  
  // 📂 HEADER DE CATEGORÍA
  Widget _buildCategoryHeader(String category, int productCount) {
    final Map<String, String> categoryIcons = {
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
    
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(
            categoryIcons[category] ?? '📦',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$productCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String companyId, bool isAdmin) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAdmin ? 'Añade tu primer producto' : 'No hay productos disponibles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAdmin
                  ? 'Comienza añadiendo productos para este proveedor'
                  : 'El administrador debe añadir productos',
              style: TextStyle(
                color: AppTheme.textColor.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, String companyId) {
    showDialog(
      context: context,
      builder: (dialogContext) => ImportProductsDialog(
        companyId: companyId,
        supplierId: widget.supplier.id,
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, String companyId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddProductDialog(
        companyId: companyId,
        supplierId: widget.supplier.id,
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final Supplier supplier;
  final String companyId;
  final bool isAdmin;

  const _ProductCard({
    required this.product,
    required this.supplier,
    required this.companyId,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showProductDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.backgroundColor,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    child: Center(
                      child: Text(
                        ProductCategories.getIcon(product.category),
                        style: TextStyle(
                          fontSize: 36, 
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // 🔴 SOLUCIÓN: Hacer flexible el precio
                        Flexible(
                          child: Text(
                            product.priceWithUnit,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8), // 🔴 SOLUCIÓN: Espacio fijo en lugar de Spacer
                        // 🔴 SOLUCIÓN: Limitar ancho máximo de categoría
                        Flexible(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 100), // 🔴 Ancho máximo
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1, // 🔴 SOLUCIÓN: Limitar a 1 línea
                              overflow: TextOverflow.ellipsis, // 🔴 SOLUCIÓN: Cortar con ...
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppTheme.textColor.withOpacity(0.6),
                  ),
                  onSelected: (value) {
                    HapticFeedback.selectionClick();
                    if (value == 'edit') _showEditProductDialog(context);
                    if (value == 'delete') _confirmDelete(context);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20), // Icono para editar
                          SizedBox(width: 12),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(), // Una línea para separar las opciones
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red), // Icono de eliminar
                          const SizedBox(width: 12),
                          Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalles de ${product.name}'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AddProductDialog(
        companyId: companyId,
        supplierId: supplier.id,
        product: product,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('⚠️ Eliminar Producto'),
        content: Text('¿Estás seguro de que quieres eliminar "${product.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // Cierra el diálogo

              // Llama al método del provider para eliminar el producto
              final provider = context.read<ProductsProvider>();
              final result = await provider.deleteProduct(
                companyId: companyId,
                productId: product.id,
                imageUrl: product.imageUrl,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['success']
                        ? '✅ Producto eliminado correctamente'
                        : result['error'] ?? '❌ Error al eliminar el producto'),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
