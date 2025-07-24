import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/product_model.dart';
import '../../providers/products_provider.dart';

class AddProductDialog extends StatefulWidget {
  final String companyId;
  final String supplierId;
  final Product? product; // Para edición

  const AddProductDialog({
    super.key,
    required this.companyId,
    required this.supplierId,
    this.product,
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _skuController = TextEditingController();

  String _selectedCategory = 'Otros';
  String _selectedUnit = 'unidad';
  bool _isLoading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      final product = widget.product!;
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toString();
      _skuController.text = product.sku ?? '';
      
      // 🔧 SOLUCIÓN: Validar que la categoría existe en la lista
      if (ProductCategories.all.contains(product.category)) {
        _selectedCategory = product.category;
      } else {
        // Si la categoría no existe, usar 'Otros' por defecto
        _selectedCategory = 'Otros';
        print('⚠️ Categoría "${product.category}" no válida, usando "Otros"');
      }
      
      // 🔧 SOLUCIÓN: Validar que la unidad existe en la lista
      if (ProductUnits.all.contains(product.unit)) {
        _selectedUnit = product.unit;
      } else {
        // Si la unidad no existe, usar 'unidad' por defecto
        _selectedUnit = 'unidad';
        print('⚠️ Unidad "${product.unit}" no válida, usando "unidad"');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<ProductsProvider>(context, listen: false);
    final isEditing = widget.product != null;

    try {
      final price = double.parse(_priceController.text.replaceAll(',', '.'));
      Map<String, dynamic> result;

      if (isEditing) {
        result = await provider.updateProduct(
          companyId: widget.companyId,
          productId: widget.product!.id,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          price: price,
          unit: _selectedUnit,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
          imageFile: _imageFile,
          currentImageUrl: widget.product!.imageUrl,
        );
      } else {
        result = await provider.createProduct(
          companyId: widget.companyId,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          price: price,
          unit: _selectedUnit,
          supplierId: widget.supplierId,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
          imageFile: _imageFile,
        );
      }

      if (!mounted) return;

      if (result['success']) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Producto actualizado' : 'Producto creado'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error desconocido'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ NUEVO MÉTODO: Muestra un diálogo para seleccionar la categoría.
  Future<void> _showCategoryPicker() async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📁 Seleccionar Categoría'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400, // Altura fija para evitar overflow
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ProductCategories.all.length,
              itemBuilder: (BuildContext context, int index) {
                final category = ProductCategories.all[index];
                final isSelected = category == _selectedCategory;
                
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
                  ),
                  child: ListTile(
                    leading: Text(
                      ProductCategories.getIcon(category), 
                      style: const TextStyle(fontSize: 24)
                    ),
                    title: Text(
                      category,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
                    onTap: () {
                      Navigator.of(context).pop(category);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (result != null && ProductCategories.all.contains(result)) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isEditing ? Icons.edit : Icons.add_box, color: AppTheme.primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Editar Producto' : 'Nuevo Producto',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildImagePicker(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del producto *',
                    prefixIcon: const Icon(Icons.inventory_2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 16),

                // ✅ SOLUCIÓN: Usar un campo de texto falso que abre un diálogo de selección.
                InkWell(
                  onTap: _showCategoryPicker,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Categoría *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Text(ProductCategories.getIcon(_selectedCategory), style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_selectedCategory)),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: InputDecoration(
                    labelText: 'Unidad *',
                    prefixIcon: const Icon(Icons.straighten),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  // 🔧 SOLUCIÓN: Añadir validación extra para evitar errores
                  items: ProductUnits.all.map((unit) => DropdownMenuItem(
                    value: unit, 
                    child: Text(unit),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null && ProductUnits.all.contains(value)) {
                      setState(() => _selectedUnit = value);
                    }
                  },
                  validator: (value) {
                    if (value == null || !ProductUnits.all.contains(value)) {
                      return 'Selecciona una unidad válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Precio *',
                    prefixIcon: const Icon(Icons.euro),
                    suffixText: '€',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}'))],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'El precio es obligatorio';
                    final price = double.tryParse(value.replaceAll(',', '.'));
                    if (price == null || price <= 0) return 'Introduce un precio válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _skuController,
                  decoration: InputDecoration(
                    labelText: 'SKU / Código (opcional)',
                    prefixIcon: const Icon(Icons.qr_code),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción (opcional)',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(), 
                      child: const Text('Cancelar')
                    ),
                    const SizedBox(width: 8),
                    // SOLUCIÓN: Botón con gradiente igual que "Añadir al Pedido"
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6B73FF), // Primary color
                            Color(0xFF4ECDC4), // Success color (menta)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6B73FF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, 
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEditing ? 'Actualizar' : 'Guardar',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                    : (widget.product?.imageUrl != null && widget.product!.imageUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                  imageUrl: widget.product!.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => _buildImagePlaceholder(),
                )
                    : _buildImagePlaceholder(),
              ),
              if (_imageFile == null && (widget.product?.imageUrl == null || widget.product!.imageUrl!.isEmpty))
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.7), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text('Añadir imagen', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
