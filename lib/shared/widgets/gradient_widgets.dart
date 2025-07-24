import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_theme.dart';

// 🎨 CONTENEDOR CON GRADIENTE TEMÁTICO ADAPTATIVO
class GradientContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final BorderRadius? borderRadius;

  const GradientContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.gradient,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.getPrimaryGradient(context),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// 🎨 BOTÓN CON GRADIENTE TEMÁTICO ADAPTATIVO
class GradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.gradient,
    this.textColor,
    this.padding,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveGradient = gradient ?? AppGradients.getPrimaryGradient(context);
    
    return AnimatedOpacity(
      opacity: isDisabled ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: isDisabled 
            ? LinearGradient(
                colors: isDark 
                  ? [Colors.grey.shade700, Colors.grey.shade800]
                  : [Colors.grey.shade400, Colors.grey.shade500]
              )
            : effectiveGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDisabled ? [] : [
            BoxShadow(
              color: effectiveGradient.colors.first.withOpacity(isDark ? 0.4 : 0.3),
              blurRadius: isDark ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          textColor ?? Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else if (icon != null) ...[
                    Icon(
                      icon,
                      color: textColor ?? Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 🎨 CARD CON GRADIENTE SUTIL TEMÁTICO
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: AppGradients.getCardGradient(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: elevation ?? (isDark ? 12 : 10),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// 🎨 CONTENEDOR DE ESTADÍSTICAS TEMÁTICO ADAPTATIVO
class StatsContainer extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const StatsContainer({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

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
              gradient: AppGradients.getPrimaryGradient(context),
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

// 🎨 BADGE PERSONALIZADO TEMÁTICO
class CustomBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const CustomBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

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

// 🎨 HEADER CON GRADIENTE ADAPTATIVO
class GradientHeader extends StatelessWidget {
  final Widget child;
  final double? height;
  final bool includeBackground;

  const GradientHeader({
    super.key,
    required this.child,
    this.height,
    this.includeBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!includeBackground) {
      return child;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: AppGradients.getHeaderGradient(context),
      ),
      child: child,
    );
  }
}

// 🎨 FLOATING ACTION BUTTON CON GRADIENTE TEMÁTICO
class GradientFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Gradient? gradient;

  const GradientFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppGradients.getPrimaryGradient(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: Colors.transparent,
      elevation: isDark ? 8 : 6,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: effectiveGradient.colors.first.withOpacity(isDark ? 0.4 : 0.3),
              blurRadius: isDark ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// 🎨 CONTENEDOR DE INFORMACIÓN TEMÁTICO
class InfoContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoContainer({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppTheme.getPrimaryColor(context)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppTheme.getPrimaryColor(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🎨 DIVIDER TEMÁTICO
class ThemeDivider extends StatelessWidget {
  final double? height;
  final double? thickness;
  final Color? color;

  const ThemeDivider({
    super.key,
    this.height,
    this.thickness,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Divider(
      height: height ?? 1,
      thickness: thickness ?? 1,
      color: color ?? (isDark ? AppTheme.darkDividerColor : AppTheme.dividerColor),
    );
  }
}
