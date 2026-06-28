import 'dart:math' as math;
import 'package:flutter/material.dart';
class ConfettiParticle {
  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
}
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});
  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}
class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<ConfettiParticle> _particles = <ConfettiParticle>[];
  final math.Random _random = math.Random();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _controller
      ..addListener(() {
        _updateParticles();
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _particles.clear();
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spawnParticles();
      _controller.forward(from: 0);
    });
  }
  void _spawnParticles() {
    final size = MediaQuery.sizeOf(context);
    final colors = <Color>[
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.yellowAccent,
    ];
    for (var i = 0; i < 100; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 3.0 + _random.nextDouble() * 6.0;
      _particles.add(
        ConfettiParticle(
          x: size.width / 2 + (_random.nextDouble() * 120 - 60),
          y: size.height / 3.5 + (_random.nextDouble() * 80 - 40),
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 2.5,
          color: colors[_random.nextInt(colors.length)],
          size: 8.0 + _random.nextDouble() * 8.0,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.25,
        ),
      );
    }
  }
  void _updateParticles() {
    final size = MediaQuery.sizeOf(context);
    for (final p in _particles) {
      p
        ..x += p.vx
        ..y += p.vy
        ..vy += 0.25
        ..vx *= 0.97
        ..rotation += p.rotationSpeed;
    }
    _particles.removeWhere(
      (p) => p.y > size.height || p.x < -30 || p.x > size.width + 30,
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(particles: _particles),
      ),
    );
  }
}
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles});
  final List<ConfettiParticle> particles;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      paint.color = p.color;
      canvas
        ..save()
        ..translate(p.x, p.y)
        ..rotate(p.rotation)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        )
        ..restore();
    }
  }
  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
