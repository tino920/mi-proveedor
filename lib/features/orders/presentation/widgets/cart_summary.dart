import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/orders_provider.dart';
import '../../../../shared/models/order_item_model.dart'; // Usando OrderItem como tipo correcto
import 'product_quantity_dialog.dart';
import '../../../products/providers/products_provider.dart';
import '../../../../shared/models/product_model.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context);
    // FIX: Usar .values.toList() directamente del mapa del carrito
    final items = ordersProvider.cartItems.values.toList();

    // Agrupar por categoría
    // FIX: Usar 'OrderItem' como el tipo de la lista
    final itemsByCategory = <String, List<OrderItem>>{};
    for (final item in items) {
      itemsByCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del Carrito',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${items.length} productos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          if (items.isEmpty) ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tu carrito está vacío',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: itemsByCategory.length,
                itemBuilder: (context, index) {
                  final category = itemsByCategory.keys.elementAt(index);
                  final categoryItems = itemsByCategory[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header de categoría
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),

                      // Items
                      ...categoryItems.map((item) => _CartItemTile(item: item)),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),

            // Total y acciones
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '€${ordersProvider.cartTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Vaciar Carrito'),
                                  content: const Text('¿Estás seguro de que quieres eliminar todos los productos del carrito?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ordersProvider.clearCart();
                                        Navigator.of(dialogContext).pop();
                                        // No es necesario un segundo pop aquí si el carrito se vacía
                                      },
                                      child: const Text(
                                        'Vaciar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Vaciar Carrito'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Continuar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  // FIX: Usar 'OrderItem'
  final OrderItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          item.productName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${item.quantity} ${item.unit} × €${item.unitPrice.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '€${item.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                  // Necesitamos el producto completo, por ahora solo actualizamos cantidad
                    showDialog(
                      context: context,
                      builder: (dialogContext) => _SimpleQuantityDialog(
                        item: item,
                        onConfirm: (quantity) {
                          ordersProvider.updateQuantity(item.productId, quantity);
                        },
                      ),
                    );
                    break;
                  case 'delete':
                    ordersProvider.removeFromCart(item.productId);
                    if (ordersProvider.cartItemCount == 0) {
                      Navigator.of(context).pop();
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 12),
                      Text('Editar cantidad'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Diálogo simple para editar cantidad cuando no tenemos el producto completo
class _SimpleQuantityDialog extends StatefulWidget {
  // FIX: Usar 'OrderItem'
  final OrderItem item;
  final Function(double) onConfirm;

  const _SimpleQuantityDialog({
    required this.item,
    required this.onConfirm,
  });

  @override
  State<_SimpleQuantityDialog> createState() => _SimpleQuantityDialogState();
}

class _SimpleQuantityDialogState extends State<_SimpleQuantityDialog> {
  late TextEditingController _controller;
  late double _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
    _controller = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar cantidad - ${widget.item.productName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Cantidad',
              suffixText: widget.item.unit,
            ),
            onChanged: (value) {
              final newQuantity = double.tryParse(value);
              if (newQuantity != null && newQuantity > 0) {
                setState(() => _quantity = newQuantity);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_quantity);
            Navigator.of(context).pop();
          },
          child: const Text('Actualizar'),
        ),
      ],
    );
  }
}