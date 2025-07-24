import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/order_model.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  final bool showIcon;
  final bool isLarge;

  const OrderStatusChip({
    super.key,
    required this.status,
    this.showIcon = true,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(status);
    final size = isLarge ? 1.2 : 1.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: (12 * size).toDouble(),
        vertical: (8 * size).toDouble(),
      ),
      decoration: BoxDecoration(
        // SOLUCIÓN: Gradiente hermoso según el estado
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusData.color,
            statusData.color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusData.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusData.icon,
                size: (16 * size).toDouble(),
                color: Colors.white,
              ),
            ),
            SizedBox(width: (8 * size).toDouble()),
          ],
          Text(
            statusData.text,
            style: TextStyle(
              fontSize: (13 * size).toDouble(),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // SOLUCIÓN: Clase de datos para organizar mejor la información del estado
  StatusData _getStatusData(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return StatusData(
          color: const Color(0xFF718096),
          icon: Icons.edit_outlined,
          text: 'Borrador',
        );
      case OrderStatus.pending:
        return StatusData(
          color: const Color(0xFFFF8A80), // Coral suave de MiProveedor
          icon: Icons.schedule_outlined,
          text: 'Pendiente',
        );
      case OrderStatus.approved:
        return StatusData(
          color: const Color(0xFF4ECDC4), // Verde menta de MiProveedor
          icon: Icons.check_circle_outline,
          text: 'Aprobado',
        );
      case OrderStatus.rejected:
        return StatusData(
          color: const Color(0xFFFF6B6B), // Rojo suave de MiProveedor
          icon: Icons.cancel_outlined,
          text: 'Rechazado',
        );
      case OrderStatus.sent:
        return StatusData(
          color: const Color(0xFF6B73FF), // Azul primario de MiProveedor
          icon: Icons.send_outlined,
          text: 'Enviado',
        );
      case OrderStatus.completed:
        return StatusData(
          color: const Color(0xFF805AD5),
          icon: Icons.done_all_outlined,
          text: 'Completado',
        );
    }
  }
}

// SOLUCIÓN: Clase de datos para organizar la información del estado
class StatusData {
  final Color color;
  final IconData icon;
  final String text;

  const StatusData({
    required this.color,
    required this.icon,
    required this.text,
  });
}
