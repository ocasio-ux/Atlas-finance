import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';

class AtlasLogo extends StatefulWidget {
  const AtlasLogo({super.key, this.size = 96});

  final double size;

  @override
  State<AtlasLogo> createState() => _AtlasLogoState();
}

class _AtlasLogoState extends State<AtlasLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final growth = Curves.easeInOut.transform(_controller.value);
      return Transform.scale(
        scale: 1 + growth * .08,
        child: CustomPaint(
          size: Size(widget.size, widget.size * 205 / 172),
          painter: _AtlasLogoPainter(glow: growth),
        ),
      );
    },
  );
}

class _AtlasLogoPainter extends CustomPainter {
  const _AtlasLogoPainter({required this.glow});
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 172;
    canvas.save();
    canvas.scale(scale, size.height / 205);
    final paint = Paint()
      ..color = AtlasColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final paths = <Path>[
      Path()..moveTo(65, 27)..quadraticBezierTo(86, 10, 107, 27)..lineTo(99, 38)..quadraticBezierTo(86, 32, 73, 38)..close(),
      Path()..moveTo(69, 37)..cubicTo(42, 44, 33, 66, 36, 94)..cubicTo(38, 116, 54, 125, 72, 125),
      Path()..moveTo(102, 38)..cubicTo(126, 47, 135, 68, 132, 94)..cubicTo(130, 111, 120, 120, 108, 123),
      Path()..moveTo(36, 86)..cubicTo(22, 92, 24, 113, 38, 126)..cubicTo(51, 138, 65, 136, 77, 135),
      Path()..moveTo(132, 88)..cubicTo(145, 94, 143, 116, 130, 128)..cubicTo(120, 137, 111, 136, 102, 134),
      Path()..addOval(const Rect.fromLTWH(79, 105, 39, 39)),
      Path()..moveTo(79, 130)..cubicTo(70, 145, 62, 155, 58, 169)..lineTo(55, 190),
      Path()..moveTo(60, 164)..lineTo(83, 153)..lineTo(101, 160)..lineTo(79, 177)..lineTo(66, 190),
      Path()..moveTo(54, 190)..lineTo(41, 190)..lineTo(35, 198)..cubicTo(62, 194, 109, 194, 139, 199),
    ];
    for (final path in paths) canvas.drawPath(path, paint);
    final dollar = TextPainter(
      text: TextSpan(
        text: r'$',
        style: TextStyle(
          color: AtlasColors.green.withValues(alpha: .86 + glow * .14),
          fontSize: 45,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    dollar.paint(canvas, const Offset(72, 54));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AtlasLogoPainter oldDelegate) =>
      oldDelegate.glow != glow;
}
