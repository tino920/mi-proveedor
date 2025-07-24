import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/models/product_model.dart';

class AddProductToOrderDialog extends StatefulWidget {
  final Product product;
  final double? initialQuantity; // ✅ NUEVO: Cantidad inicial
  final String? initialNotes;   // ✅ NUEVO: Notas iniciales

  const AddProductToOrderDialog({
    super.key,
    required this.product,
    this.initialQuantity, // ✅ NUEVO: Parámetro opcional
    this.initialNotes,    // ✅ NUEVO: Parámetro opcional
  });

  @override
  State<AddProductToOrderDialog> createState() => _AddProductToOrderDialogState();
}

class _AddProductToOrderDialogState extends State<AddProductToOrderDialog> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _quantityFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();
  double _quantity = 1.0;

  @override
  void initState() {
    super.initState();
    
    // ✅ INICIALIZAR con la cantidad actual del carrito o 1
    _quantity = widget.initialQuantity ?? 1.0;
    _quantityController.text = _quantity.toString();
    
    // ✅ INICIALIZAR con las notas existentes
    if (widget.initialNotes != null) {
      _notesController.text = widget.initialNotes!;
    }
    
    // ✅ HEMOS QUITADO LA LÍNEA QUE ABRÍA EL TECLADO AUTOMÁTICAMENTE
    // Ahora solo pre-selecciona el texto si el usuario toca el campo.
    _quantityFocus.addListener(() {
      if (_quantityFocus.hasFocus) {
        _quantityController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _quantityController.text.length,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ SOLUCIÓN: Usar Padding con MediaQuery para manejar el teclado
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // ✅ ALTURA DINÁMICA que se ajusta al teclado
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle para arrastar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header fijo
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                // Imagen del producto
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF8F9FA),
                    border: Border.all(
                      color: const Color(0xFF6B73FF).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: widget.product.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF6B73FF),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.inventory_2,
                        color: Color(0xFF6B73FF),
                        size: 30,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.inventory_2,
                    color: Color(0xFF6B73FF),
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
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B73FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.product.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B73FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '€${widget.product.price.toStringAsFixed(2)} / ${widget.product.unit}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4ECDC4),
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón cerrar
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),

          // ✅ CONTENIDO SCROLLEABLE con manejo mejorado del teclado
          Expanded(
            child: Padding(
              // ✅ AJUSTE DINÁMICO al teclado
              padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  keyboardHeight > 0 ? 16 : 24
              ),
              child: SingleChildScrollView(
                // ✅ CLAVE: physics para mejor scroll
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cantidad
                    const Text(
                      'Cantidad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Controles de cantidad
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          // Botón decrementar
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B73FF).withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => _decrementQuantity(),
                              icon: const Icon(Icons.remove, size: 24),
                              color: const Color(0xFF6B73FF),
                              iconSize: 28,
                            ),
                          ),

                          // Campo de cantidad
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: TextField(
                                controller: _quantityController,
                                focusNode: _quantityFocus,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey.shade400,
                                  ),
                                  suffix: Text(
                                    widget.product.unit,
                                    style: const TextStyle(
                                      color: Color(0xFF718096),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _quantity = double.tryParse(value) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                          ),

                          // Botón incrementar
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4).withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => _incrementQuantity(),
                              icon: const Icon(Icons.add, size: 24),
                              color: const Color(0xFF4ECDC4),
                              iconSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Notas opcionales
                    const Text(
                      'Notas (opcional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ CAMPO DE NOTAS MEJORADO para el teclado
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: _notesController,
                        focusNode: _notesFocus,
                        maxLines: 4,
                        minLines: 4,
                        style: const TextStyle(fontSize: 16),
                        // ✅ CONFIGURACIÓN MEJORADA para scroll automático
                        onTap: () {
                          // Scroll automático cuando se toca el campo de notas
                          Future.delayed(const Duration(milliseconds: 300), () {
                            Scrollable.ensureVisible(
                              _notesFocus.context!,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Ej: Corte especial, sin piel, etc.',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Total destacado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6B73FF).withOpacity(0.1),
                            const Color(0xFF4ECDC4).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6B73FF).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            '€${(_quantity * widget.product.price).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B73FF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ ESPACIO EXTRA cuando el teclado está visible
                    if (keyboardHeight > 0) SizedBox(height: keyboardHeight + 20),

                    const SizedBox(height: 120), // Espacio para los botones fijos
                  ],
                ),
              ),
            ),
          ),

          // ✅ BOTONES FIJOS EN LA PARTE INFERIOR (no se mueven con el scroll)
          Container(
            padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                24 + MediaQuery.of(context).padding.bottom
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Botón Añadir
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B73FF), Color(0xFF4ECDC4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B73FF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _quantity > 0 ? _addToOrder : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Añadir al Pedido',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _incrementQuantity() {
    setState(() {
      _quantity += _getIncrementStep();
      _quantityController.text = _quantity.toString();
    });
    HapticFeedback.lightImpact();
  }

  void _decrementQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity = (_quantity - _getIncrementStep()).clamp(0.0, double.infinity);
        _quantityController.text = _quantity.toString();
      });
      HapticFeedback.lightImpact();
    }
  }

  double _getIncrementStep() {
    switch (widget.product.unit.toLowerCase()) {
      case 'kg':
      case 'l':
      case 'litro':
      case 'litros':
        return 0.5;
      case 'g':
      case 'ml':
        return 100.0;
      default:
        return 1.0;
    }
  }

  void _addToOrder() {
    if (_quantity <= 0) return;

    // ✅ OCULTAR TECLADO antes de cerrar
    FocusScope.of(context).unfocus();

    HapticFeedback.mediumImpact();
    Navigator.of(context).pop({
      'quantity': _quantity,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _quantityFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }
}