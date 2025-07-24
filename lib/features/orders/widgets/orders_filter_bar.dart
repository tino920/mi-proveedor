import 'package:flutter/material.dart';
import '../../../shared/models/order_model.dart';


class OrdersFilterBar extends StatelessWidget {
  final OrderStatus? selectedStatus; // Cambiado a anulable para manejar "Todos"
  final Function(OrderStatus?) onStatusChanged; // Cambiado a anulable para manejar "Todos"

  const OrdersFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por estado:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Todos',
                  // No se le asigna un status específico
                  isSelected: selectedStatus == null,
                  onTap: () => onStatusChanged(null), // Pasar null para "Todos"
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Pendientes',
                  status: OrderStatus.pending,
                  isSelected: selectedStatus == OrderStatus.pending,
                  onTap: () => onStatusChanged(OrderStatus.pending),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Aprobados',
                  status: OrderStatus.approved,
                  isSelected: selectedStatus == OrderStatus.approved,
                  onTap: () => onStatusChanged(OrderStatus.approved),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Enviados',
                  status: OrderStatus.sent,
                  isSelected: selectedStatus == OrderStatus.sent,
                  onTap: () => onStatusChanged(OrderStatus.sent),
                ),
                const SizedBox(width: 8),
                // NUEVO CHIP AÑADIDO PARA 'COMPLETADOS'
                _buildFilterChip(
                  label: 'Completados',
                  status: OrderStatus.completed,
                  isSelected: selectedStatus == OrderStatus.completed,
                  onTap: () => onStatusChanged(OrderStatus.completed),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Rechazados',
                  status: OrderStatus.rejected,
                  isSelected: selectedStatus == OrderStatus.rejected,
                  onTap: () => onStatusChanged(OrderStatus.rejected),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    OrderStatus? status, // Cambiado a anulable para el chip "Todos"
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Usar un color y un icono por defecto si el status es nulo (para "Todos")
    final color = status != null ? _getStatusColor(status) : Colors.blueGrey;
    final icon = status != null ? _getStatusIcon(status) : Icons.list;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
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
    // NUEVO CASO AÑADIDO
      case OrderStatus.completed:
        return const Color(0xFF6B73FF);
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Icons.edit;
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.approved:
        return Icons.check_circle;
      case OrderStatus.rejected:
        return Icons.cancel;
      case OrderStatus.sent:
        return Icons.send;
    // NUEVO CASO AÑADIDO
      case OrderStatus.completed:
        return Icons.done_all;
    }
  }
}