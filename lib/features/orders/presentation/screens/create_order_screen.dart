import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/product_model.dart';
import '../../providers/orders_provider.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/order_item_model.dart'; // ✅ AÑADIDO
import '../../../../core/auth/auth_provider.dart';
import '../../../products/providers/products_provider.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/add_product_to_order_dialog.dart';

class CreateOrderScreen extends StatefulWidget {
  final Supplier supplier;
  final Order? editingOrder; // ✅ NUEVO: Pedido para editar

  const CreateOrderScreen({
    super.key,
    required this.supplier,
    this.editingOrder, // ✅ NUEVO: Parámetro opcional
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedCategory = 'Todas';
  List<String> _categories = ['Todas'];
  Order? _currentOrder;
  bool _categoriesInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeOrder();
  }

  Future<void> _initializeOrder() async {
    final authProvider = Provider.of<RestauAuthProvider>(
        context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    if (authProvider.user != null && authProvider.companyId != null) {
      Order? order;

      // ✅ NUEVO: Verificar si estamos editando
      if (widget.editingOrder != null) {
        // Modo edición: usar pedido existente
        order = widget.editingOrder;
        ordersProvider.loadOrderForEditing(order!);
      } else {
        // Modo creación: crear nuevo borrador
        order = await ordersProvider.createDraftOrder(
          companyId: authProvider.companyId!,
          employeeId: authProvider.user!.uid,
          employeeName: authProvider.currentUser?.name ?? 'Usuario',
          supplierId: widget.supplier.id,
          supplierName: widget.supplier.name,
        );
      }

      if (mounted) {
        setState(() {
          _currentOrder = order;
        });
      }
    }
  }

  void _updateCategories(List<Product> products) {
    if (!_categoriesInitialized || products.isEmpty) {
      final uniqueCategories = products
          .map((p) => p.category)
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();

      uniqueCategories.sort();

      final newCategories = ['Todas'] + uniqueCategories;

      if (mounted && newCategories.toString() != _categories.toString()) {
        setState(() {
          _categories = newCategories;
          _categoriesInitialized = true;

          if (!_categories.contains(_selectedCategory)) {
            _selectedCategory = 'Todas';
          }
        });
      }
    }
  }
  /// ✅ Lógica corregida para guardar los cambios
  Future<void> _submitUpdate() async {
    final ordersProvider = context.read<OrdersProvider>();
    final authProvider = context.read<RestauAuthProvider>(); // <-- Leemos el AuthProvider
    final companyId = authProvider.companyId; // <-- Obtenemos el companyId

    // Verificamos que tenemos todo lo necesario
    if (companyId == null || widget.editingOrder == null) {
      _showErrorSnackBar('Error: No se pudo identificar la empresa o el pedido.');
      return;
    }

    final success = await ordersProvider.updateExistingOrder(
      companyId: companyId, // <-- Pasamos el companyId a la función
      order: widget.editingOrder!,
      notes: _notesController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop(); // Cierra el resumen
      Navigator.of(context).pop(); // Cierra la pantalla de edición

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ Pedido actualizado correctamente' : '❌ Error al actualizar el pedido'),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text(
                // ✅ NUEVO: Título dinámico según modo
                widget.editingOrder != null ? 'Editar Pedido' : 'Crear Pedido',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                // ✅ NUEVO: Subtítulo dinámico
                widget.editingOrder != null
                    ? '#${widget.editingOrder!.orderNumber}'
                    : widget.supplier.name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Consumer<OrdersProvider>(
              builder: (context, ordersProvider, _) {
                if (ordersProvider.currentOrder?.items.isNotEmpty ?? false) {
                  return IconButton(
                    onPressed: () => _showOrderSummary(context),
                    icon: Stack(
                      children: [
                        const Icon(Icons.shopping_cart, color: Colors.white),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${ordersProvider.currentOrder?.items.length ?? 0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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
                        prefixIcon: const Icon(
                            Icons.search,
                            color: AppTheme.primaryColor,
                            size: 24
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return _buildCategoryChip(category);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Consumer<ProductsProvider>(
                  builder: (context, productsProvider, _) {
                    return StreamBuilder<List<Product>>(
                      stream: productsProvider.getProductsStream(
                        widget.supplier.companyId,
                        widget.supplier.id,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final products = snapshot.data ?? [];

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _updateCategories(products);
                        });

                        final filteredProducts = _filterProducts(products);

                        if (filteredProducts.isEmpty) {
                          return Center(child: Text(
                              _selectedCategory == 'Todas' && _searchController.text.isNotEmpty
                                  ? 'No se encontraron productos'
                                  : 'No hay productos en esta categoría'
                          ));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return _buildProductCard(context, product);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Consumer<OrdersProvider>(
          builder: (context, ordersProvider, _) {
            if (ordersProvider.currentOrder?.items.isEmpty ?? true) {
              return const SizedBox.shrink();
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppGradients.buttonGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showOrderSummary(context),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                icon: const Icon(Icons.shopping_cart, size: 24),
                label: Text(
                  '€${ordersProvider.currentOrder?.total.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () => _openProductDetails(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.inventory_2, color: AppTheme.primaryColor, size: 30),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.priceWithUnit,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<OrdersProvider>(
                builder: (context, ordersProvider, _) {
                  final currentQuantity = ordersProvider.cartItems[product.id]?.quantity ?? 0;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón menos (solo visible si hay productos)
                      if (currentQuantity > 0)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                            onPressed: () => _decreaseQuantity(product.id, currentQuantity),
                          ),
                        ),

                      // Contador (solo visible si hay productos)
                      if (currentQuantity > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primaryColor, width: 1),
                          ),
                          child: Text(
                            currentQuantity.toInt().toString(),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Botón más
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add, color: Colors.white, size: 20),
                          onPressed: () => _increaseQuantity(product),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase().trim();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query) ||
            (product.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_selectedCategory != 'Todas') {
      filtered = filtered.where((product) {
        return product.category.toLowerCase() ==
            _selectedCategory.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  Future<void> _addProductToOrder(Product product) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => AddProductToOrderDialog(product: product),
    );

    if (result != null) {
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
      final success = await ordersProvider.addProductToOrder(
        product: product,
        quantity: result['quantity'],
        notes: result['notes'],
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${product.name} añadido al pedido'),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ✅ MÉTODO PARA ABRIR DETALLES DEL PRODUCTO (TAP EN TARJETA)
  Future<void> _openProductDetails(Product product) async {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    // ✅ OBTENER CANTIDAD Y NOTAS ACTUALES DEL CARRITO
    final currentQuantity = ordersProvider.cartItems[product.id]?.quantity ?? 1.0;
    final currentNotes = ordersProvider.cartItems[product.id]?.notes;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => AddProductToOrderDialog(
        product: product,
        initialQuantity: currentQuantity, // ✅ PASAR CANTIDAD ACTUAL
        initialNotes: currentNotes,       // ✅ PASAR NOTAS ACTUALES
      ),
    );

    if (result != null) {
      // ✅ SI EL PRODUCTO YA EXISTÍA, ACTUALIZAR O ELIMINAR
      if (ordersProvider.cartItems.containsKey(product.id)) {
        final newQuantity = result['quantity'] as double;

        if (newQuantity <= 0) {
          // ✅ ELIMINAR del carrito si la cantidad es 0
          ordersProvider.removeFromCart(product.id);
        } else {
          // ✅ ACTUALIZAR cantidad y notas
          ordersProvider.updateQuantity(product.id, newQuantity);

          // Luego actualizar las notas manualmente
          final currentOrder = ordersProvider.currentOrder!;
          final itemIndex = currentOrder.items.indexWhere((item) => item.productId == product.id);
          if (itemIndex != -1) {
            final currentItem = currentOrder.items[itemIndex];
            final updatedItem = currentItem.copyWith(notes: result['notes']);
            currentOrder.items[itemIndex] = updatedItem;
            ordersProvider.notifyListeners();
          }
        }
      } else {
        // ✅ NUEVO PRODUCTO - Solo añadir si cantidad > 0
        final newQuantity = result['quantity'] as double;
        if (newQuantity > 0) {
          final success = await ordersProvider.addProductToOrder(
            product: product,
            quantity: newQuantity,
            notes: result['notes'],
          );

          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al añadir ${product.name}'),
                backgroundColor: AppTheme.warningColor,
              ),
            );
            return;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${product.name} actualizado'),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ✅ NUEVOS MÉTODOS PARA LOS BOTONES + Y -
  Future<void> _increaseQuantity(Product product) async {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final success = await ordersProvider.addProductToOrder(
      product: product,
      quantity: 1.0, // Añadir 1 unidad
      notes: null,   // Sin comentarios por defecto
    );

    if (success && mounted) {
      // Feedback visual sutil
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} (+1)'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _decreaseQuantity(String productId, double currentQuantity) {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    if (currentQuantity > 1) {
      // Si hay más de 1, reducir cantidad
      ordersProvider.updateQuantity(productId, currentQuantity - 1);
    } else {
      // Si solo hay 1, eliminar del carrito
      ordersProvider.removeFromCart(productId);
    }

    // Feedback visual sutil
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto (-1)'),
        backgroundColor: AppTheme.warningColor,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showOrderSummary(BuildContext context) {
    // ✅ OBTENEMOS EL ROL DEL USUARIO ANTES DE MOSTRAR EL RESUMEN
    final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
    final bool isAdmin = authProvider.isAdmin;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderSummaryCard(
        onNotesChanged: (notes) {
          _notesController.text = notes;
        },
        // ✅ PASAMOS EL ROL AL MÉTODO QUE SE EJECUTARÁ
        onSubmitForApproval: () => _submitForApproval(isAdmin: isAdmin),
      ),
    );
  }

  // ✅ ACTUALIZAMOS LA FIRMA DEL MÉTODO PARA RECIBIR EL ROL
  Future<void> _submitForApproval({required bool isAdmin}) async {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);

    final success = await ordersProvider.submitOrderForApproval(
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      // ✅ PASAMOS EL ROL Y EL NOMBRE DEL ADMIN AL PROVIDER
      isAdmin: isAdmin,
      adminName: authProvider.currentUser?.name,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.send, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(isAdmin ? 'Pedido creado y aprobado' : 'Pedido enviado para aprobación'),
              ),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(ordersProvider.error ?? 'Error al enviar pedido'),
              ),
            ],
          ),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

