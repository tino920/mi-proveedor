import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_theme.dart';

/// 🎨 WIDGET PARA TRANSICIONES SUAVES ENTRE TEMAS
/// Este widget hace que los cambios de tema sean más fluidos y profesionales
class ThemeAwareAnimatedContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final bool useGradientBackground;

  const ThemeAwareAnimatedContainer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
    this.useGradientBackground = false,
  }) : super(key: key);

  @override
  State<ThemeAwareAnimatedContainer> createState() => _ThemeAwareAnimatedContainerState();
}

class _ThemeAwareAnimatedContainerState extends State<ThemeAwareAnimatedContainer>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Decoration effectiveDecoration = widget.decoration ?? BoxDecoration(
      color: widget.useGradientBackground 
          ? null 
          : AppTheme.getCardColor(context),
      gradient: widget.useGradientBackground 
          ? AppGradients.getPrimaryGradient(context)
          : null,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: theme.brightness == Brightness.dark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.1),
          blurRadius: theme.brightness == Brightness.dark ? 12 : 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return AnimatedContainer(
      duration: widget.duration,
      curve: Curves.easeInOutCubic,
      padding: widget.padding,
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      constraints: widget.constraints,
      alignment: widget.alignment,
      decoration: effectiveDecoration,
      child: widget.child,
    );
  }
}

/// 🌈 BOTÓN CON GRADIENTE ANIMADO QUE SE ADAPTA AL TEMA
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.gradient,
    this.padding,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppGradients.getPrimaryGradient(context);
    final isDisabled = !isEnabled || onPressed == null || isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height ?? 50,
      decoration: BoxDecoration(
        gradient: isDisabled 
            ? LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              )
            : effectiveGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDisabled ? null : [
          BoxShadow(
            color: effectiveGradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
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
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// 📊 CARD ADAPTATIVA CON ESTADÍSTICAS
class ThemeAwareStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final String? subtitle;

  const ThemeAwareStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor,
    this.onTap,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveAccentColor = accentColor ?? AppTheme.getPrimaryColor(context);

    return ThemeAwareAnimatedContainer(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: effectiveAccentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔄 SWITCH TEMÁTICO ANIMADO
class ThemeToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? title;
  final String? subtitle;

  const ThemeToggleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemeAwareAnimatedContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (title != null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                ],
              ),
            ),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: value 
                  ? AppGradients.getPrimaryGradient(context)
                  : LinearGradient(
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade400,
                      ],
                    ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  top: 2,
                  left: value ? 22 : 2,
                  child: GestureDetector(
                    onTap: () => onChanged(!value),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
}

/// 🌊 CONTENEDOR CON EFECTO WAVE PARA HEADERS
class WaveHeaderContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final LinearGradient? gradient;

  const WaveHeaderContainer({
    Key? key,
    required this.child,
    this.height = 200,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.getHeaderGradient(context),
      ),
      child: Stack(
        children: [
          // Efectos de ondas sutiles
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),
          // Contenido principal
          SafeArea(child: child),
        ],
      ),
    );
  }
}

/// 🎯 BADGE CON ANIMACIÓN DE PULSO
class PulseBadge extends StatefulWidget {
  final String text;
  final Color? color;
  final bool isPulsing;

  const PulseBadge({
    Key? key,
    required this.text,
    this.color,
    this.isPulsing = true,
  }) : super(key: key);

  @override
  State<PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<PulseBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppTheme.getPrimaryColor(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPulsing ? _animation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.isPulsing ? [
                BoxShadow(
                  color: effectiveColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
