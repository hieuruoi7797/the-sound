import 'package:flutter/material.dart';

class FrequencyVisualizer extends StatelessWidget {
  final List<double> frequencies;

  const FrequencyVisualizer({
    super.key,
    required this.frequencies,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FrequencyPainter(frequencies),
      child: Container(),
    );
  }
}

class FrequencyPainter extends CustomPainter {
  final List<double> frequencies;

  FrequencyPainter(this.frequencies);

  @override
  void paint(Canvas canvas, Size size) {
    if (frequencies.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final pointWidth = width / (frequencies.length - 1);

    path.moveTo(0, height / 2);

    for (var i = 0; i < frequencies.length; i++) {
      final x = pointWidth * i;
      final normalizedFrequency = frequencies[i] / 20000; // Normalize to 0-1
      final y = height / 2 + (normalizedFrequency * height / 2);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(FrequencyPainter oldDelegate) {
    return oldDelegate.frequencies != frequencies;
  }
} 