import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/supplier_model.dart';

class SupplierListItem extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SupplierListItem({
    super.key,
    required this.supplier,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen del proveedor
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: supplier.imageUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(supplier.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: supplier.imageUrl == null
                    ? const Icon(
                        Icons.business,
                        color: AppTheme.primaryColor,
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Información del proveedor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (supplier.phone != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            supplier.phone!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (supplier.email != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              supplier.email!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (supplier.deliveryDays.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDeliveryDays(supplier.deliveryDays),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Menú de opciones
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        const Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                        const SizedBox(width: 8),
                        Text(
                          'Eliminar',
                          style: TextStyle(color: AppTheme.errorColor),
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
  
  String _formatDeliveryDays(List<String> days) {
    final daysMap = {
      'monday': 'Lun',
      'tuesday': 'Mar',
      'wednesday': 'Mié',
      'thursday': 'Jue',
      'friday': 'Vie',
      'saturday': 'Sáb',
      'sunday': 'Dom',
    };
    
    return days
        .map((day) => daysMap[day.toLowerCase()] ?? day)
        .join(', ');
  }
}
