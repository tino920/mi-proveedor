import 'package:flutter/material.dart';
import '../../../shared/models/order_model.dart';


class OrderApprovalCard extends StatelessWidget {
  // SOLUCIÓN 1: Cambia el tipo de 'OrderModel' a 'Order'
  final Order order;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit;
  final VoidCallback onSend;
  final VoidCallback onViewDetails;

  const OrderApprovalCard({
    super.key,
    required this.order,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
    required this.onSend,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Pedido #${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusChip(order.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Por ${order.employeeName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(order.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '€${order.total.toStringAsFixed(2)}', // Asumiendo que el campo es 'total' y no 'totalAmount'
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B73FF),
                  ),
                ),
              ],
            ),
          ),

          // Supplier Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.store,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  order.supplierName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),

          // Products Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${order.items.length} productos',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onViewDetails,
                        child: const Text(
                          'Ver detalles',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B73FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...order.items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '• ${item.productName}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ),
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (order.items.length > 3)
                    Text(
                      '... y ${order.items.length - 3} más',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718096),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Notes
          if (order.notes != null && order.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (order.status) {
      case OrderStatus.pending:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Rechazar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB4A2),
                    foregroundColor: const Color(0xFF2D3748),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: const Color(0xFF2D3748),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Aprobar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case OrderStatus.approved:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSend,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Enviar a Proveedor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B73FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case OrderStatus.sent:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pedido enviado',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case OrderStatus.draft:
        color = Colors.grey;
        text = 'Borrador';
        icon = Icons.edit;
        break;
      case OrderStatus.pending:
        color = const Color(0xFFFFB4A2);
        text = 'Pendiente';
        icon = Icons.schedule;
        break;
      case OrderStatus.approved:
        color = const Color(0xFF4ECDC4);
        text = 'Aprobado';
        icon = Icons.check_circle;
        break;
      case OrderStatus.rejected:
        color = const Color(0xFFFF6B6B);
        text = 'Rechazado';
        icon = Icons.cancel;
        break;
      case OrderStatus.sent:
        color = Colors.green;
        text = 'Enviado';
        icon = Icons.send;
        break;
    // SOLUCIÓN 3: Añade un caso default para que las variables siempre se inicialicen
      default:
        color = Colors.black;
        text = 'Desconocido';
        icon = Icons.help_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Colors.grey;
      case OrderStatus.pending:
        return const Color(0xFFFFB4A2);
      case OrderStatus.approved:
        return const Color(0xFF4ECDC4);
      case OrderStatus.rejected:
        return const Color(0xFFFF6B6B);
      case OrderStatus.sent:
        return Colors.green;
    // SOLUCIÓN 3: Añade un caso default para que la función siempre devuelva un color
      default:
        return Colors.black;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}