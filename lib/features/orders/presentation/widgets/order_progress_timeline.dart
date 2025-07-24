import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/order_model.dart';

class OrderProgressTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? sentAt;
  final DateTime? completedAt;
  final bool isCompact;

  const OrderProgressTimeline({
    super.key,
    required this.currentStatus,
    this.createdAt,
    this.approvedAt,
    this.sentAt,
    this.completedAt,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _getOrderSteps();
    
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCompact) ...[
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Progreso del Pedido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Timeline
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _buildTimelineStep(steps[i], i == 0, i == steps.length - 1),
                if (i < steps.length - 1) _buildTimelineConnector(steps[i], steps[i + 1]),
              ],
            ],
          ),
          
          if (!isCompact) ...[
            const SizedBox(height: 12),
            _buildStatusDescription(),
          ],
        ],
      ),
    );
  }

  List<TimelineStep> _getOrderSteps() {
    return [
      TimelineStep(
        status: OrderStatus.pending,
        title: 'Creado',
        isActive: _isStatusActive(OrderStatus.pending),
        isCompleted: _isStatusCompleted(OrderStatus.pending),
        dateTime: createdAt,
      ),
      TimelineStep(
        status: OrderStatus.approved,
        title: 'Aprobado',
        isActive: _isStatusActive(OrderStatus.approved),
        isCompleted: _isStatusCompleted(OrderStatus.approved),
        dateTime: approvedAt,
      ),
      TimelineStep(
        status: OrderStatus.sent,
        title: 'Enviado',
        isActive: _isStatusActive(OrderStatus.sent),
        isCompleted: _isStatusCompleted(OrderStatus.sent),
        dateTime: sentAt,
      ),
      TimelineStep(
        status: OrderStatus.completed,
        title: 'Completado',
        isActive: _isStatusActive(OrderStatus.completed),
        isCompleted: _isStatusCompleted(OrderStatus.completed),
        dateTime: completedAt,
      ),
    ];
  }

  bool _isStatusActive(OrderStatus status) {
    return currentStatus == status;
  }

  bool _isStatusCompleted(OrderStatus status) {
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.approved,
      OrderStatus.sent,
      OrderStatus.completed,
    ];
    
    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(status);
    
    return currentIndex >= stepIndex;
  }

  Widget _buildTimelineStep(TimelineStep step, bool isFirst, bool isLast) {
    Color backgroundColor;
    Color iconColor;
    Color textColor;
    
    if (step.isCompleted) {
      backgroundColor = const Color(0xFF4ECDC4); // Verde menta
      iconColor = Colors.white;
      textColor = AppTheme.textColor;
    } else if (step.isActive) {
      backgroundColor = const Color(0xFF6B73FF); // Azul primario
      iconColor = Colors.white;
      textColor = AppTheme.textColor;
    } else {
      backgroundColor = Colors.grey.shade300;
      iconColor = Colors.grey.shade600;
      textColor = Colors.grey.shade600;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCompact ? 32 : 40,
          height: isCompact ? 32 : 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: step.isActive || step.isCompleted ? [
              BoxShadow(
                color: backgroundColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Icon(
            _getStepIcon(step.status),
            color: iconColor,
            size: isCompact ? 16 : 20,
          ),
        ),
        if (!isCompact) ...[
          const SizedBox(height: 8),
          Text(
            step.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          if (step.dateTime != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatDateTime(step.dateTime!),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildTimelineConnector(TimelineStep current, TimelineStep next) {
    final isActive = current.isCompleted && next.isCompleted;
    
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
          top: isCompact ? 16 : 20,
          left: 4,
          right: 4,
        ),
        height: 3,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4ECDC4) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStatusDescription() {
    String description;
    Color descriptionColor;
    
    switch (currentStatus) {
      case OrderStatus.pending:
        description = 'Pedido creado, esperando aprobación del administrador';
        descriptionColor = const Color(0xFFFF8A80);
        break;
      case OrderStatus.approved:
        description = 'Pedido aprobado, listo para enviar al proveedor';
        descriptionColor = const Color(0xFF4ECDC4);
        break;
      case OrderStatus.sent:
        description = 'Pedido enviado al proveedor, esperando confirmación';
        descriptionColor = const Color(0xFF6B73FF);
        break;
      case OrderStatus.completed:
        description = 'Pedido completado exitosamente';
        descriptionColor = const Color(0xFF4ECDC4);
        break;
      case OrderStatus.rejected:
        description = 'Pedido rechazado por el administrador';
        descriptionColor = const Color(0xFFFF6B6B);
        break;
      case OrderStatus.draft:
        description = 'Pedido en borrador';
        descriptionColor = Colors.grey.shade600;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: descriptionColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: descriptionColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: descriptionColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: descriptionColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.create_outlined;
      case OrderStatus.approved:
        return Icons.check_circle_outline;
      case OrderStatus.sent:
        return Icons.send_outlined;
      case OrderStatus.completed:
        return Icons.done_all_outlined;
      case OrderStatus.rejected:
        return Icons.cancel_outlined;
      case OrderStatus.draft:
        return Icons.edit_outlined;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Ahora';
    }
  }
}

class TimelineStep {
  final OrderStatus status;
  final String title;
  final bool isActive;
  final bool isCompleted;
  final DateTime? dateTime;

  const TimelineStep({
    required this.status,
    required this.title,
    required this.isActive,
    required this.isCompleted,
    this.dateTime,
  });
}
