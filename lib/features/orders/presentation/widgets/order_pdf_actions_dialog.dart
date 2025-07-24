import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../suppliers/providers/suppliers_provider.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/order_pdf_actions.dart';

class OrderPdfActionsDialog extends StatefulWidget {
  final Order order;

  const OrderPdfActionsDialog({
    super.key,
    required this.order,
  });

  @override
  State<OrderPdfActionsDialog> createState() => _OrderPdfActionsDialogState();
}

class _OrderPdfActionsDialogState extends State<OrderPdfActionsDialog> {
  bool _isLoading = false;
  ShareMethod _selectedMethod = ShareMethod.both;
  String? _errorMessage;
  Supplier? _supplier;

  @override
  void initState() {
    super.initState();
    _loadSupplier();
  }

  Future<void> _loadSupplier() async {
    final suppliersProvider = context.read<SuppliersProvider>();
    final suppliers = suppliersProvider.suppliers;
    _supplier = suppliers.firstWhere(
      (s) => s.id == widget.order.supplierId,
      orElse: () => Supplier(
        id: widget.order.supplierId,
        name: widget.order.supplierName,
        deliveryDays: [],
        companyId: widget.order.companyId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFF6B73FF),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Generar y Enviar PDF',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        'Pedido #${widget.order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

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
                  Row(
                    children: [
                      const Icon(
                        Icons.business,
                        size: 20,
                        color: Color(0xFF6B73FF),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.order.supplierName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        size: 20,
                        color: Color(0xFF6B73FF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.order.items.length} productos',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '€${widget.order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B73FF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Método de envío
            const Text(
              'Método de envío:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),

            const SizedBox(height: 12),

            // Opciones de envío
            Column(
              children: ShareMethod.values.map((method) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: _isLoading ? null : () {
                      setState(() {
                        _selectedMethod = method;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedMethod == method
                              ? const Color(0xFF6B73FF)
                              : const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedMethod == method
                            ? const Color(0xFF6B73FF).withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            method.icon,
                            color: _selectedMethod == method
                                ? const Color(0xFF6B73FF)
                                : const Color(0xFF718096),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              method.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _selectedMethod == method
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: _selectedMethod == method
                                    ? const Color(0xFF6B73FF)
                                    : const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          if (_selectedMethod == method)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF6B73FF),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFFF6B6B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _generateAndSendPdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B73FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Generar y Enviar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndSendPdf() async {
    if (_supplier == null) {
      setState(() {
        _errorMessage = 'No se pudo cargar la información del proveedor';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<RestauAuthProvider>();
      final ordersProvider = context.read<OrdersProvider>();

      // Datos de la empresa
      final companyData = {
        'name': authProvider.companyData?['name'] ?? 'MiProveedor',
        'address': authProvider.companyData?['address'] ?? '',
        'phone': authProvider.companyData?['phone'] ?? '',
        'email': authProvider.userData?['email'] ?? '',
      };

      // Generar y enviar PDF
      final result = await OrderPdfActions.generateAndShare(
        order: widget.order,
        supplier: _supplier!,
        companyData: companyData,
        method: _selectedMethod,
      );

      if (result['success']) {
        // Actualizar estado del pedido a "enviado"
        await ordersProvider.sendOrderToSupplier(
          companyId: widget.order.companyId,
          orderId: widget.order.id,
          method: _selectedMethod.name,
        );

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'PDF generado y enviado exitosamente'),
              backgroundColor: const Color(0xFF4ECDC4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Error desconocido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
