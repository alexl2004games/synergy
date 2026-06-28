import 'dart:ui';
import 'package:flutter/material.dart';
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.borderRadius = 16.0,
    this.blur = 18.0,
    this.borderOpacity = 0.15,
    this.bgOpacity = 0.08,
    this.margin,
    this.padding,
    super.key,
  });
  final Widget child;
  final double borderRadius;
  final double blur;
  final double borderOpacity;
  final double bgOpacity;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.black.withValues(alpha: bgOpacity * 1.5)
        : Colors.white.withValues(alpha: (bgOpacity * 4).clamp(0.0, 0.92));
    final borderColor = isDark
        ? Colors.white.withValues(alpha: borderOpacity)
        : Colors.black.withValues(alpha: borderOpacity);
    final innerContainer = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: child,
    );
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: blur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: innerContainer,
              )
            : innerContainer,
      ),
    );
  }
}
