import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_proveedor/core/auth/auth_provider.dart';

// SOLUCIÓN: Añade el import para que Dart sepa qué es OrdersProvider
import '../providers/orders_provider.dart';

import '../../../shared/models/order_model.dart';

class OrderStatsOverview extends StatelessWidget {
  const OrderStatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<RestauAuthProvider>(context);
    final companyId = authProvider.companyId;

    if (companyId == null) {
      return const SizedBox.shrink(); // O un mensaje de error
    }

    return StreamBuilder<List<Order>>(
      stream: Provider.of<OrdersProvider>(context).getOrdersStream(companyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          ); // O un placeholder de carga
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar estadísticas: ${snapshot.error}'),
          );
        }

        final orders = snapshot.data ?? [];

        final pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;
        final approvedCount = orders.where((o) => o.status == OrderStatus.approved).length;
        final sentCount = orders.where((o) => o.status == OrderStatus.sent).length;
        final totalAmount = orders.fold<double>(0, (sum, order) => sum + order.total);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de Pedidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pendientes',
                      value: pendingCount.toString(),
                      color: const Color(0xFFFFB4A2),
                      icon: Icons.schedule,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Aprobados',
                      value: approvedCount.toString(),
                      color: const Color(0xFF4ECDC4),
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Enviados',
                      value: sentCount.toString(),
                      color: Colors.green,
                      icon: Icons.send,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B73FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.euro,
                      color: Color(0xFF6B73FF),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valor Total de Pedidos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                        Text(
                          '€${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B73FF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}