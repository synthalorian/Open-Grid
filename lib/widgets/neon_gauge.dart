import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/grid_theme.dart';

class NeonGauge extends StatelessWidget {
  final String label;
  final double value; // 0-100
  final Color color;
  final String? suffix;
  final String? detail;

  const NeonGauge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.suffix = '%',
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: _GaugePainter(value: value, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${value.toStringAsFixed(1)}${suffix ?? ''}',
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail!,
                      style: const TextStyle(
                        color: GridTheme.textDim,
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;

  _GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const startAngle = 2.3562; // 135 degrees
    const totalSweep = 4.7124; // 270 degrees

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      Paint()
        ..color = GridTheme.gridLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Value arc
    final sweep = totalSweep * (value / 100).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Glow effect
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Tick marks
    for (int i = 0; i <= 10; i++) {
      final tickAngle = startAngle + (totalSweep * i / 10);
      final outerPoint = Offset(
        center.dx + (radius + 2) * math.cos(tickAngle),
        center.dy + (radius + 2) * math.sin(tickAngle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 4) * math.cos(tickAngle),
        center.dy + (radius - 4) * math.sin(tickAngle),
      );
      canvas.drawLine(
        innerPoint,
        outerPoint,
        Paint()
          ..color = GridTheme.textDim
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      value != old.value || color != old.color;
}

class NeonGraph extends StatelessWidget {
  final String label;
  final List<double> data;
  final Color color;
  final double maxValue;

  const NeonGraph({
    super.key,
    required this.label,
    required this.data,
    required this.color,
    this.maxValue = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: CustomPaint(
            painter: _GraphPainter(data: data, color: color, maxValue: maxValue),
          ),
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double maxValue;

  _GraphPainter({required this.data, required this.color, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Grid
    final gridPaint = Paint()
      ..color = GridTheme.gridLine
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data line
    final path = Path();
    final fillPath = Path();
    final step = size.width / (data.length - 1).clamp(1, double.infinity);

    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height - (data[i] / maxValue * size.height).clamp(0.0, size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo((data.length - 1) * step, size.height);
    fillPath.close();

    // Fill gradient
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
