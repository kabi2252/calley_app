import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CalleyDonutChart extends StatelessWidget {
  final int pending;
  final int done;
  final int schedule;
  final double size;

  const CalleyDonutChart({
    super.key,
    required this.pending,
    required this.done,
    required this.schedule,
    this.size = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    final total = pending + done + schedule;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartPainter(
              pending: pending,
              done: done,
              schedule: schedule,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final int pending;
  final int done;
  final int schedule;

  _DonutChartPainter({
    required this.pending,
    required this.done,
    required this.schedule,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = (pending + done + schedule).toDouble();
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.40;
    final strokeWidth = size.width * 0.16;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final pendingSweep = (pending / total) * 2 * pi;
    final doneSweep = (done / total) * 2 * pi;
    final scheduleSweep = (schedule / total) * 2 * pi;

    const gap = 0.08; // gap between segments in radians

    double startAngle = -pi / 2;

    // 1. Pending (Yellow/Orange)
    final pendingPaint = Paint()
      ..color = AppColors.pendingOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle + gap / 2, pendingSweep - gap, false, pendingPaint);
    startAngle += pendingSweep;

    // 2. Done (Cyan/Blue)
    final donePaint = Paint()
      ..color = AppColors.doneCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle + gap / 2, doneSweep - gap, false, donePaint);
    startAngle += doneSweep;

    // 3. Schedule (Purple)
    final schedulePaint = Paint()
      ..color = AppColors.schedulePurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle + gap / 2, scheduleSweep - gap, false, schedulePaint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.pending != pending ||
        oldDelegate.done != done ||
        oldDelegate.schedule != schedule;
  }
}
