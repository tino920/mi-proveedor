import 'package:flutter/material.dart';

class AppGradients {
  // 🌅 GRADIENTES MODO CLARO
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B73FF), // Azul suave
      Color(0xFF4ECDC4), // Verde menta/turquesa
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF6B73FF),
      Color(0xFF4ECDC4),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF6B73FF),
      Color(0xFF4ECDC4),
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFFFFFFF),
    ],
  );

  // Gradiente para éxito/confirmación
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4ECDC4), // Verde menta
      Color(0xFF44D09E), // Verde suave
    ],
  );

  // Gradiente para advertencias
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB4A2), // Coral delicado
      Color(0xFFFFD93D), // Amarillo dorado
    ],
  );

  // Gradiente para errores
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE74C3C), // Rojo
      Color(0xFFFF6B6B), // Rojo más suave
    ],
  );

  // 🌙 GRADIENTES MODO OSCURO
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B93FF), // Azul más claro para contraste
      Color(0xFF5EFDD4), // Verde menta más brillante
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF8B93FF), // Azul más claro
      Color(0xFF5EFDD4), // Verde menta brillante
    ],
  );

  static const LinearGradient darkButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF8B93FF),
      Color(0xFF5EFDD4),
    ],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF121212), // Negro carbón
      Color(0xFF1E1E1E), // Gris muy oscuro
    ],
  );

  // Gradiente oscuro para éxito/confirmación
  static const LinearGradient darkSuccessGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5EFDD4), // Verde menta brillante
      Color(0xFF54E6B4), // Verde brillante
    ],
  );

  // Gradiente oscuro para advertencias
  static const LinearGradient darkWarningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFCAB2), // Coral más claro
      Color(0xFFFFE55D), // Amarillo más claro
    ],
  );

  // Gradiente oscuro para errores
  static const LinearGradient darkErrorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B), // Rojo más suave
      Color(0xFFFF8E53), // Rojo-naranja suave
    ],
  );

  // 🌊 GRADIENTES SUTILES PARA CARDS
  static const LinearGradient lightCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFAFBFC), // Blanco azulado muy sutil
      Color(0xFFFFFFFF), // Blanco puro
    ],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D2D2D), // Gris oscuro
      Color(0xFF353535), // Gris oscuro más claro
    ],
  );

  // 🎨 GRADIENTES PARA ESTADOS DE PEDIDOS
  static const LinearGradient pendingGradient = LinearGradient(
    colors: [Color(0xFFFFB4A2), Color(0xFFFFD93D)],
  );

  static const LinearGradient approvedGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44D09E)],
  );

  static const LinearGradient rejectedGradient = LinearGradient(
    colors: [Color(0xFFE74C3C), Color(0xFFFF6B6B)],
  );

  static const LinearGradient sentGradient = LinearGradient(
    colors: [Color(0xFF6B73FF), Color(0xFF4ECDC4)],
  );

  // Versiones oscuras para estados de pedidos
  static const LinearGradient darkPendingGradient = LinearGradient(
    colors: [Color(0xFFFFCAB2), Color(0xFFFFE55D)],
  );

  static const LinearGradient darkApprovedGradient = LinearGradient(
    colors: [Color(0xFF5EFDD4), Color(0xFF54E6B4)],
  );

  static const LinearGradient darkRejectedGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );

  static const LinearGradient darkSentGradient = LinearGradient(
    colors: [Color(0xFF8B93FF), Color(0xFF5EFDD4)],
  );

  // 🎯 MÉTODOS HELPER PARA OBTENER GRADIENTES SEGÚN EL TEMA
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkPrimaryGradient 
        : primaryGradient;
  }

  static LinearGradient getHeaderGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkHeaderGradient 
        : headerGradient;
  }

  static LinearGradient getButtonGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkButtonGradient 
        : buttonGradient;
  }

  static LinearGradient getBackgroundGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBackgroundGradient 
        : backgroundGradient;
  }

  static LinearGradient getSuccessGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSuccessGradient 
        : successGradient;
  }

  static LinearGradient getWarningGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkWarningGradient 
        : warningGradient;
  }

  static LinearGradient getErrorGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkErrorGradient 
        : errorGradient;
  }

  static LinearGradient getCardGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkCardGradient 
        : lightCardGradient;
  }

  // Métodos para gradientes de estados de pedidos
  static LinearGradient getOrderStatusGradient(BuildContext context, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pendiente':
        return isDark ? darkPendingGradient : pendingGradient;
      case 'approved':
      case 'aprobado':
        return isDark ? darkApprovedGradient : approvedGradient;
      case 'rejected':
      case 'rechazado':
        return isDark ? darkRejectedGradient : rejectedGradient;
      case 'sent':
      case 'enviado':
        return isDark ? darkSentGradient : sentGradient;
      default:
        return getPrimaryGradient(context);
    }
  }
}

// 🎨 EXTENSIÓN PARA ACCESO FÁCIL A GRADIENTES TEMÁTICOS
extension AppGradientsExtension on BuildContext {
  LinearGradient get primaryGradient => AppGradients.getPrimaryGradient(this);
  LinearGradient get headerGradient => AppGradients.getHeaderGradient(this);
  LinearGradient get buttonGradient => AppGradients.getButtonGradient(this);
  LinearGradient get backgroundGradient => AppGradients.getBackgroundGradient(this);
  LinearGradient get successGradient => AppGradients.getSuccessGradient(this);
  LinearGradient get warningGradient => AppGradients.getWarningGradient(this);
  LinearGradient get errorGradient => AppGradients.getErrorGradient(this);
  LinearGradient get cardGradient => AppGradients.getCardGradient(this);
}
