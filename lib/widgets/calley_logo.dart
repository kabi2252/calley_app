import 'package:flutter/material.dart';

class CalleyLogo extends StatelessWidget {
  final double height;
  final bool showSubtitle;

  const CalleyLogo({
    super.key,
    this.height = 36.0,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/calley_logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // High-fidelity vector fallback matching Calley branding
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(height, height),
              painter: _CalleyVectorLogoPainter(),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CALLEY',
                  style: TextStyle(
                    fontSize: height * 0.45,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: const Color(0xFF1E293B),
                    height: 1.0,
                  ),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    'AUTOMATIC CALL DIALER',
                    style: TextStyle(
                      fontSize: height * 0.18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: const Color(0xFF94A3B8),
                      height: 1.0,
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CalleyVectorLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    final paint1 = Paint()
      ..color = const Color(0xFFEC4899)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Two interlocking colorful arcs
    canvas.drawArc(rect, -1.2, 2.6, false, paint1);
    canvas.drawArc(rect, 1.8, 2.6, false, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
