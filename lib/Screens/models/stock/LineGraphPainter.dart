import 'package:flutter/material.dart';

class LineGraphPainter extends CustomPainter {
  final List<String> dates;
  final List<double> prices;

  LineGraphPainter(this.dates, this.prices);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    final double stepX = size.width / (prices.length - 1);
    final double maxPrice = prices.reduce((value, element) => value > element ? value : element);
    final double minPrice = prices.reduce((value, element) => value < element ? value : element);
    final double stepY = size.height / (maxPrice - minPrice);

    path.moveTo(0, size.height - (prices[0] - minPrice) * stepY);

    for (int i = 1; i < prices.length; i++) {
      path.lineTo(i * stepX, size.height - (prices[i] - minPrice) * stepY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
