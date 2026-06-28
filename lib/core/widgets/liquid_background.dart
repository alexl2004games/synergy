import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
class LiquidBackground extends StatefulWidget {
  const LiquidBackground({super.key});
  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}
class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF0D0D1E)
        : const Color(0xFFF0F2FA);
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: baseColor),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = _controller.value * math.pi * 2;
            final blob1X = size.width * 0.1 + math.sin(value) * 60;
            final blob1Y = size.height * 0.15 + math.cos(value) * 80;
            final blob2X = size.width * 0.6 + math.cos(value + 1.0) * 80;
            final blob2Y = size.height * 0.55 + math.sin(value + 1.0) * 90;
            final blob3X = size.width * 0.2 + math.sin(value + 2.0) * 70;
            final blob3Y = size.height * 0.7 + math.cos(value + 2.0) * 70;
            return Stack(
              children: [
                Positioned(
                  left: blob1X,
                  top: blob1Y,
                  child: _GradientBlob(
                    size: size.width * 0.8,
                    color: const Color(0xFFFF2E93)
                        .withValues(alpha: isDark ? 0.22 : 0.14),
                  ),
                ),
                Positioned(
                  left: blob2X,
                  top: blob2Y,
                  child: _GradientBlob(
                    size: size.width * 0.85,
                    color: const Color(0xFF00FFA3)
                        .withValues(alpha: isDark ? 0.18 : 0.11),
                  ),
                ),
                Positioned(
                  left: blob3X,
                  top: blob3Y,
                  child: _GradientBlob(
                    size: size.width * 0.75,
                    color: const Color(0xFF6F00FF)
                        .withValues(alpha: isDark ? 0.24 : 0.13),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
            child: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
class _GradientBlob extends StatelessWidget {
  const _GradientBlob({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
