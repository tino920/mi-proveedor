import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/suppliers_provider.dart';
import '../../../../shared/models/supplier_model.dart'; // 🆕 Contiene SupplierTypeUtils

class AddSupplierDialog extends StatefulWidget {
  final String companyId;
  final Supplier? supplier; // null para crear, con valor para editar

  const AddSupplierDialog({
    super.key,
    required this.companyId,
    this.supplier,
  });

  @override
  State<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  File? _imageFile;
  List<String> _selectedDays = [];
  String _selectedType = 'mixto'; // 🆕 NUEVO: Tipo de proveedor
  bool _isLoading = false;

  final List<String> _weekDays = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.name;
      _descriptionController.text = widget.supplier!.description ?? '';
      _emailController.text = widget.supplier!.email ?? '';
      _phoneController.text = widget.supplier!.phone ?? '';
      _addressController.text = widget.supplier!.address ?? '';
      _selectedDays = List.from(widget.supplier!.deliveryDays);
      _selectedType = widget.supplier!.type ?? 'mixto'; // 🆕 NUEVO
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final provider = Provider.of<SuppliersProvider>(context, listen: false);
    final file = await provider.pickImage();

    if (file != null) {
      setState(() => _imageFile = file);
    }
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<SuppliersProvider>(context, listen: false);
    Map<String, dynamic> result;

    if (widget.supplier == null) {
      // Crear nuevo proveedor
      result = await provider.createSupplier(
        companyId: widget.companyId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        deliveryDays: _selectedDays,
        imageFile: _imageFile,
        type: _selectedType, // 🆕 NUEVO CAMPO
      );
    } else {
      // Actualizar proveedor existente
      result = await provider.updateSupplier(
        companyId: widget.companyId,
        supplierId: widget.supplier!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        deliveryDays: _selectedDays,
        imageFile: _imageFile,
        existingImageUrl: widget.supplier!.imageUrl,
        type: _selectedType, // 🆕 NUEVO CAMPO
      );
    }

    setState(() => _isLoading = false);

    if (result['success'] && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.supplier == null
              ? 'Proveedor creado correctamente'
              : 'Proveedor actualizado correctamente'
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al guardar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ SOLUCIÓN TECLADO: Envolver el Dialog en un AlertDialog para mejor manejo de tamaño.
    // Y el contenido en un SingleChildScrollView para que sea desplazable.
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Eliminar el padding por defecto para tener control total.
      contentPadding: EdgeInsets.zero,
      // El contenido es una columna que puede desplazarse.
      content: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),

              // Content (Formulario)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePicker(),
                      const SizedBox(height: 24),
                      _buildTextFormFields(),
                      const SizedBox(height: 20),
                      _buildDeliveryDaysPicker(),
                    ],
                  ),
                ),
              ),

              // Actions (Botones)
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.supplier == null ? Icons.add_business : Icons.edit,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            widget.supplier == null ? 'Nuevo Proveedor' : 'Editar Proveedor',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    // ✅ SOLUCIÓN FOTO: El GestureDetector ahora envuelve todo el Stack.
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : (widget.supplier?.imageUrl != null && widget.supplier!.imageUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                  imageUrl: widget.supplier!.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => _buildImagePlaceholder(),
                )
                    : _buildImagePlaceholder(),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                // IgnorePointer para asegurar que el tap llegue al GestureDetector de arriba.
                child: const IgnorePointer(
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Proveedor *',
            hintText: 'Ej: Carnes del Mar',
            prefixIcon: Icon(Icons.business),
          ),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Por favor ingresa el nombre' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Breve descripción del proveedor',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        // 🆕 NUEVO: Selector de tipo de proveedor
        _buildTypeSelector(),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'correo@ejemplo.com',
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) => (value != null && value.isNotEmpty && !value.contains('@')) ? 'Ingresa un email válido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            hintText: '123 456 789',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            hintText: 'Calle, número, ciudad',
            prefixIcon: Icon(Icons.location_on),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDeliveryDaysPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Días de Entrega',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _weekDays.map((day) {
            final isSelected = _selectedDays.contains(day);
            return FilterChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(day);
                  } else {
                    _selectedDays.remove(day);
                  }
                });
              },
              selectedColor: AppTheme.successColor.withOpacity(0.2),
              checkmarkColor: AppTheme.successColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _isLoading ? null : _saveSupplier,
            borderRadius: BorderRadius.circular(12), // Para que el efecto de toque sea redondeado
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                // ✅ Aquí usas el gradiente de tu app
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isLoading ? [] : [ // Sombra opcional para darle profundidad
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _isLoading
                    ? [ // Contenido cuando está cargando
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                ]
                    : [ // Contenido normal del botón (ícono y texto)
                  Icon(
                    widget.supplier == null ? Icons.add : Icons.save,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.supplier == null ? 'Crear' : 'Guardar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 40,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Añadir foto',
            style: TextStyle(
              color: AppTheme.primaryColor.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 NUEVO: Selector de tipo de proveedor
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Productos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Los filtros se adaptarán automáticamente según los productos que añadas',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SupplierTypeUtils.allTypes.map((type) {
            final isSelected = _selectedType == type;
            final icon = SupplierTypeUtils.getTypeIcon(type);
            final name = SupplierTypeUtils.getTypeName(type);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor
                        : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}