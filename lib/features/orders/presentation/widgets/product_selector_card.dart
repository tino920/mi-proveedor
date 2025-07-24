import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/models/product_model.dart';

class ProductSelectorCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductSelectorCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen del producto
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF8F9FA),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF6B73FF),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            _getCategoryIcon(product.category),
                            color: const Color(0xFF6B73FF),
                            size: 30,
                          ),
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(product.category),
                        color: const Color(0xFF6B73FF),
                        size: 30,
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Categoría
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(product.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getCategoryColor(product.category),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descripción (si existe)
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      Text(
                        product.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Precio
                    Row(
                      children: [
                        Text(
                          '€${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B73FF),
                          ),
                        ),
                        Text(
                          ' / ${product.unit}',
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
              
              // Botón de añadir
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pescados y mariscos':
      case 'pescado':
      case 'mariscos':
        return Icons.set_meal;
      case 'carnes':
      case 'carne':
        return Icons.lunch_dining;
      case 'verduras':
      case 'vegetales':
        return Icons.eco;
      case 'frutas':
        return Icons.apple;
      case 'lácteos':
      case 'lacteos':
        return Icons.icecream;
      case 'panadería':
      case 'panaderia':
        return Icons.bakery_dining;
      case 'bebidas':
        return Icons.local_drink;
      case 'condimentos':
        return Icons.rice_bowl;
      case 'aceites y vinagres':
        return Icons.water_drop;
      case 'congelados':
        return Icons.ac_unit;
      default:
        return Icons.inventory_2;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'pescados y mariscos':
      case 'pescado':
      case 'mariscos':
        return const Color(0xFF3182CE);
      case 'carnes':
      case 'carne':
        return const Color(0xFFE53E3E);
      case 'verduras':
      case 'vegetales':
        return const Color(0xFF38A169);
      case 'frutas':
        return const Color(0xFFDD6B20);
      case 'lácteos':
      case 'lacteos':
        return const Color(0xFF805AD5);
      case 'panadería':
      case 'panaderia':
        return const Color(0xFFD69E2E);
      case 'bebidas':
        return const Color(0xFF00B5D8);
      case 'condimentos':
        return const Color(0xFF718096);
      case 'aceites y vinagres':
        return const Color(0xFFF56565);
      case 'congelados':
        return const Color(0xFF4299E1);
      default:
        return const Color(0xFF6B73FF);
    }
  }
}
