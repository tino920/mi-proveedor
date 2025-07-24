import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/product_model.dart';

class ProductQuantityDialog extends StatefulWidget {
  final Product product;
  final double initialQuantity;
  final Function(double) onConfirm;
  
  const ProductQuantityDialog({
    super.key,
    required this.product,
    required this.initialQuantity,
    required this.onConfirm,
  });

  @override
  State<ProductQuantityDialog> createState() => _ProductQuantityDialogState();
}

class _ProductQuantityDialogState extends State<ProductQuantityDialog> {
  late TextEditingController _quantityController;
  late double _quantity;
  
  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _quantityController = TextEditingController(text: _quantity.toString());
  }
  
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  void _updateQuantity(double delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(0.1, 9999);
      _quantityController.text = _quantity.toString();
    });
  }
  
  void _setQuantity(String value) {
    final newQuantity = double.tryParse(value);
    if (newQuantity != null && newQuantity > 0) {
      setState(() => _quantity = newQuantity);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final subtotal = widget.product.price * _quantity;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Producto info
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€${widget.product.price.toStringAsFixed(2)} / ${widget.product.unit}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Cantidad selector
            Text(
              'Cantidad',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón decrementar
                IconButton(
                  onPressed: _quantity > 0.1 ? () => _updateQuantity(-1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 16),
                
                // Campo de cantidad
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      suffixText: widget.product.unit,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _setQuantity,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Botón incrementar
                IconButton(
                  onPressed: () => _updateQuantity(1),
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botones rápidos
            Wrap(
              spacing: 8,
              children: [
                if (widget.product.unit == 'kg' || widget.product.unit == 'g') ...[
                  _QuickButton(
                    label: '+0.5',
                    onTap: () => _updateQuantity(0.5),
                  ),
                  _QuickButton(
                    label: '+2',
                    onTap: () => _updateQuantity(2),
                  ),
                  _QuickButton(
                    label: '+5',
                    onTap: () => _updateQuantity(5),
                  ),
                ] else ...[
                  _QuickButton(
                    label: '+10',
                    onTap: () => _updateQuantity(10),
                  ),
                  _QuickButton(
                    label: '+25',
                    onTap: () => _updateQuantity(25),
                  ),
                  _QuickButton(
                    label: '+50',
                    onTap: () => _updateQuantity(50),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            
            // Subtotal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '€${subtotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    widget.onConfirm(_quantity);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: Text(widget.initialQuantity > 0 ? 'Actualizar' : 'Añadir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  const _QuickButton({
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
