import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../providers/orders_provider.dart';

class OrderApprovalDialog extends StatefulWidget {
  final Order order;
  final bool isApproval; // true para aprobar, false para rechazar

  const OrderApprovalDialog({
    super.key,
    required this.order,
    required this.isApproval,
  });

  @override
  State<OrderApprovalDialog> createState() => _OrderApprovalDialogState();
}

class _OrderApprovalDialogState extends State<OrderApprovalDialog> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            widget.isApproval ? Icons.check_circle : Icons.cancel,
            color: widget.isApproval ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isApproval ? 'Aprobar Pedido' : 'Rechazar Pedido',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del pedido
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.orderNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.order.employeeName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.business,
                        size: 16,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.order.supplierName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.euro,
                        size: 16,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.order.total.toStringAsFixed(2)} (${widget.order.items.length} productos)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Campo de notas/comentarios
            Text(
              widget.isApproval ? 'Notas de aprobación (opcional)' : 'Motivo del rechazo (obligatorio)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: widget.isApproval 
                    ? 'Ej: Pedido aprobado sin modificaciones'
                    : 'Ej: Cantidad excesiva para esta semana',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.isApproval ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
                    width: 2,
                  ),
                ),
              ),
            ),
            
            // Mensaje de confirmación
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isApproval 
                    ? const Color(0xFF4ECDC4).withOpacity(0.1)
                    : const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isApproval 
                      ? const Color(0xFF4ECDC4).withOpacity(0.3)
                      : const Color(0xFFFF6B6B).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isApproval ? Icons.info : Icons.warning,
                    size: 20,
                    color: widget.isApproval ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isApproval
                          ? 'El empleado recibirá una notificación de que su pedido ha sido aprobado.'
                          : 'El empleado recibirá una notificación con el motivo del rechazo.',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isApproval ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              color: Color(0xFF718096),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isApproval ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.isApproval ? 'Aprobar' : 'Rechazar',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _handleAction() async {
    // Validar entrada para rechazos
    if (!widget.isApproval && _notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El motivo del rechazo es obligatorio'),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

      if (authProvider.user == null || authProvider.companyId == null) {
        throw Exception('Usuario no autenticado');
      }

      bool success = false;

      if (widget.isApproval) {
        success = await ordersProvider.approveOrder(
          orderId: widget.order.id,
          companyId: authProvider.companyId!,
          adminId: authProvider.user!.uid,
          adminName: authProvider.currentUser?.name ?? 'Admin',
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      } else {
        success = await ordersProvider.rejectOrder(
          orderId: widget.order.id,
          companyId: authProvider.companyId!,
          adminId: authProvider.user!.uid,
          adminName: authProvider.currentUser?.name ?? 'Admin',
          reason: _notesController.text.trim(),
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ordersProvider.error ?? 
                'Error al ${widget.isApproval ? 'aprobar' : 'rechazar'} el pedido'
              ),
              backgroundColor: const Color(0xFFFF6B6B),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
