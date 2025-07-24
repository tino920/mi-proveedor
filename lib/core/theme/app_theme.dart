import 'package:flutter/material.dart';
import 'app_gradients.dart';

class AppTheme {
  // 🌅 COLORES MODO CLARO
  static const Color primaryColor = Color(0xFF6B73FF); // Azul Suave
  static const Color successColor = Color(0xFF4ECDC4); // Verde Menta
  static const Color warningColor = Color(0xFFFFB4A2); // Coral Delicado
  static const Color backgroundColor = Color(0xFFF8F9FA); // Gris Muy Claro
  static const Color cardColor = Color(0xFFFFFFFF); // Blanco Puro
  static const Color textColor = Color(0xFF2D3748); // Gris Oscuro
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color secondaryTextColor = Color(0xFF718096);
  static const Color dividerColor = Color(0xFFE2E8F0);
  
  // 🌙 COLORES MODO OSCURO
  static const Color darkPrimaryColor = Color(0xFF8B93FF); // Azul más claro para contraste
  static const Color darkSuccessColor = Color(0xFF5EFDD4); // Verde menta más brillante
  static const Color darkWarningColor = Color(0xFFFFCAB2); // Coral más claro
  static const Color darkBackgroundColor = Color(0xFF121212); // Negro carbón
  static const Color darkSurfaceColor = Color(0xFF1E1E1E); // Gris muy oscuro
  static const Color darkCardColor = Color(0xFF2D2D2D); // Gris oscuro para cards
  static const Color darkTextColor = Color(0xFFE2E2E2); // Blanco hueso
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0); // Gris claro
  static const Color darkDividerColor = Color(0xFF404040); // Gris medio
  static const Color darkErrorColor = Color(0xFFFF6B6B); // Rojo más suave

  // 🌅 TEMA CLARO (EXISTENTE MEJORADO)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    
    // AppBar Theme con gradiente
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Button Theme con gradiente
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: secondaryTextColor),
      hintStyle: const TextStyle(color: secondaryTextColor),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Drawer Theme
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
      elevation: 16,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        color: textColor,
        fontSize: 14,
      ),
    ),


    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: successColor,
      error: errorColor,
      background: backgroundColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onBackground: textColor,
      onSurface: textColor,
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: secondaryTextColor),
      labelLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(color: secondaryTextColor),
    ),
  );

  // 🌙 TEMA OSCURO (COMPLETAMENTE NUEVO Y PROFESIONAL)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    
    // AppBar Theme para modo oscuro
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme para modo oscuro
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Button Theme para modo oscuro
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkBackgroundColor,
        elevation: 4,
        shadowColor: darkPrimaryColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button Theme para modo oscuro
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input Decoration Theme para modo oscuro
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkErrorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkErrorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: darkSecondaryTextColor),
      hintStyle: const TextStyle(color: darkSecondaryTextColor),
    ),
    
    // Bottom Navigation Bar Theme para modo oscuro
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: darkPrimaryColor,
      unselectedItemColor: darkSecondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // Floating Action Button Theme para modo oscuro
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: darkPrimaryColor,
      foregroundColor: darkBackgroundColor,
      elevation: 8,
      shape: CircleBorder(),
    ),
    
    // Chip Theme para modo oscuro
    chipTheme: ChipThemeData(
      backgroundColor: darkPrimaryColor.withOpacity(0.2),
      labelStyle: const TextStyle(color: darkPrimaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Drawer Theme para modo oscuro
    drawerTheme: const DrawerThemeData(
      backgroundColor: darkSurfaceColor,
      elevation: 16,
    ),

    // Dialog Theme para modo oscuro
    dialogTheme: DialogThemeData(
      backgroundColor: darkCardColor,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        color: darkTextColor,
        fontSize: 14,
      ),
    ),


    // Switch Theme para modo oscuro
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return darkPrimaryColor;
        }
        return darkSecondaryTextColor;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return darkPrimaryColor.withOpacity(0.5);
        }
        return darkDividerColor;
      }),
    ),

    // Divider Theme para modo oscuro
    dividerTheme: const DividerThemeData(
      color: darkDividerColor,
      thickness: 1,
    ),
    
    // Color Scheme para modo oscuro
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPrimaryColor,
      brightness: Brightness.dark,
      primary: darkPrimaryColor,
      secondary: darkSuccessColor,
      error: darkErrorColor,
      background: darkBackgroundColor,
      surface: darkCardColor,
      onPrimary: darkBackgroundColor,
      onSecondary: darkBackgroundColor,
      onError: darkBackgroundColor,
      onBackground: darkTextColor,
      onSurface: darkTextColor,
    ),

    // Text Theme para modo oscuro
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: darkTextColor, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: darkTextColor, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
      bodySmall: TextStyle(color: darkSecondaryTextColor),
      labelLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: darkTextColor, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(color: darkSecondaryTextColor),
    ),
  );

  // 🎨 MÉTODOS HELPER PARA OBTENER COLORES SEGÚN EL TEMA
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkPrimaryColor 
        : primaryColor;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBackgroundColor 
        : backgroundColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkCardColor 
        : cardColor;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextColor 
        : textColor;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSecondaryTextColor 
        : secondaryTextColor;
  }

  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSuccessColor 
        : successColor;
  }

  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkErrorColor 
        : errorColor;
  }
}

// 🎨 WIDGET GRADIENT CONTAINER MEJORADO PARA AMBOS TEMAS
class GradientContainer extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? height;
  final double? width;

  const GradientContainer({
    Key? key,
    required this.child,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? (isDark 
            ? AppGradients.darkPrimaryGradient 
            : AppGradients.primaryGradient),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// 🎨 CONTENEDOR DE ESTADÍSTICAS ADAPTATIVO
class StatsContainer extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const StatsContainer({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: isDark ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isDark 
                  ? AppGradients.darkPrimaryGradient 
                  : AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// 🎨 BADGE PERSONALIZADO ADAPTATIVO
class CustomBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const CustomBadge({
    Key? key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.getPrimaryColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// 🎨 EXTENSIÓN PARA ACCESO FÁCIL A COLORES TEMÁTICOS
extension AppThemeExtension on BuildContext {
  Color get primaryColor => AppTheme.getPrimaryColor(this);
  Color get backgroundColor => AppTheme.getBackgroundColor(this);
  Color get cardColor => AppTheme.getCardColor(this);
  Color get textColor => AppTheme.getTextColor(this);
  Color get secondaryTextColor => AppTheme.getSecondaryTextColor(this);
  Color get successColor => AppTheme.getSuccessColor(this);
  Color get errorColor => AppTheme.getErrorColor(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
