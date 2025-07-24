import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/orders_provider.dart';
import '../../../../shared/models/order_item_model.dart';

class OrderSummaryCard extends StatefulWidget {
  final Function(String) onNotesChanged;
  final VoidCallback onSubmitForApproval;

  const OrderSummaryCard({
    super.key,
    required this.onNotesChanged,
    required this.onSubmitForApproval,
  });

  @override
  State<OrderSummaryCard> createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Usamos una altura máxima para que se adapte al contenido
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Hace que la columna ocupe solo el espacio necesario
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Text(
                  'Resumen del Pedido',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF718096),
                ),
              ],
            ),
          ),

          // Lista de productos y notas (ahora en un SingleChildScrollView)
          Expanded(
            child: SingleChildScrollView(
              child: Consumer<OrdersProvider>(
                builder: (context, ordersProvider, _) {
                  final order = ordersProvider.currentOrder;
                  if (order == null || order.items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 80.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Color(0xFF718096),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay productos en el pedido',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Lista de productos
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: order.items.length,
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return _buildOrderItem(context, item, ordersProvider);
                        },
                      ),

                      const Divider(height: 24),

                      // Notas
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notas del pedido (opcional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // ✅ CAMBIOS REALIZADOS AQUÍ
                            TextField(
                              controller: _notesController,
                              maxLines: 1, // Una sola línea
                              decoration: InputDecoration(
                                hintText: 'Añade información adicional...',
                                // Hacemos el campo más compacto
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF6B73FF), width: 2),
                                ),
                              ),
                              onChanged: widget.onNotesChanged,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ),

          // Total y botón (siempre visible abajo)
          Consumer<OrdersProvider>(
              builder: (context, ordersProvider, _) {
                final order = ordersProvider.currentOrder;
                if (order == null || order.items.isEmpty) {
                  return const SizedBox.shrink(); // No mostrar si no hay items
                }
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
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
                              '${order.items.length} productos',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF718096),
                              ),
                            ),
                            Text(
                              '€${order.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              '€${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B73FF),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: ordersProvider.isLoading ? null : widget.onSubmitForApproval,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4ECDC4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: ordersProvider.isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Enviar para Aprobación',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item, OrdersProvider ordersProvider) {
    // ... (este método no necesita cambios)
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF8F9FA),
            ),
            child: item.imageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6B73FF),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.inventory_2,
                  color: Color(0xFF6B73FF),
                  size: 24,
                ),
              ),
            )
                : const Icon(
              Icons.inventory_2,
              color: Color(0xFF6B73FF),
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantityText} × ${item.unitPriceText}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
                if (item.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.totalPriceText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B73FF),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _editQuantity(context, item, ordersProvider),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF6B73FF),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  InkWell(
                    onTap: () => _removeItem(context, item, ordersProvider),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editQuantity(BuildContext context, OrderItem item, OrdersProvider ordersProvider) {
    final quantityController = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar cantidad de ${item.productName}'),
        content: TextField(
          controller: quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Cantidad (${item.unit})',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = double.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity > 0) {
                ordersProvider.updateProductQuantity(item.productId, newQuantity);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _removeItem(BuildContext context, OrderItem item, OrdersProvider ordersProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Estás seguro de que quieres eliminar ${item.productName} del pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ordersProvider.removeProductFromOrder(item.productId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
