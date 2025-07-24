import 'package:flutter/material.dart';
// ⚠️ ¡IMPORTANTE! Asegúrate de que esta ruta a tus gradientes sea correcta.
import '../../core/theme/app_gradients.dart';

class SupplierIconWidget extends StatelessWidget {
  final double size;

  const SupplierIconWidget({
    super.key,
    this.size = 80.0, // Tamaño por defecto si no se especifica uno
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Usa el gradiente que ya tienes definido en tu app
        gradient: AppGradients.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.local_shipping, // El ícono del camión
          color: Colors.white,
          // El tamaño del ícono se ajusta automáticamente al tamaño del círculo
          size: size * 0.55,
        ),
      ),
    );
  }
}