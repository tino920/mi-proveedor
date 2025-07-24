import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PendingOrdersCard extends StatelessWidget {
  const PendingOrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalle del pedido
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del proveedor
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del pedido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carnes Del Mar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pedido #2024-001',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppTheme.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'María García',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hace 5 min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Total y acciones
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€245.50',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pending,
                          size: 14,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pendiente',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
