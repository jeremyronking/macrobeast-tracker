import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MacroRing extends StatelessWidget {
  final double value;
  final double max;
  final Color color;
  final String label;
  final String unit;
  final String size; // 'sm', 'md', 'lg'

  const MacroRing({
    super.key,
    required this.value,
    required this.max,
    required this.color,
    required this.label,
    required this.unit,
    this.size = 'md',
  });

  @override
  Widget build(BuildContext context) {
    double width, radius, fontSize, strokeWidth;

    switch (size) {
      case 'lg':
        width = 160;
        radius = 70;
        fontSize = 24;
        strokeWidth = 10;
        break;
      case 'sm':
        width = 60;
        radius = 25;
        fontSize = 12;
        strokeWidth = 5; // slimmer for small
        break;
      case 'md':
      default:
        width = 100;
        radius = 40;
        fontSize = 14;
        strokeWidth = 8;
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyColor = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFE5E7EB);

    // Ensure we don't divide by zero or have negative values
    final safeMax = max > 0 ? max : 1.0;
    final safeValue = value.clamp(0.0, safeMax);
    final remainder = safeMax - safeValue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          height: width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: radius - strokeWidth,
                  startDegreeOffset: 270,
                  sections: [
                    PieChartSectionData(
                      color: color,
                      value: safeValue,
                      showTitle: false,
                      radius: strokeWidth,
                      title: '', // Hide generic title
                    ),
                    PieChartSectionData(
                      color: emptyColor,
                      value: remainder,
                      showTitle: false,
                      radius: strokeWidth,
                      title: '',
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (size == 'lg')
                    Text(
                      'of ${max.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (size != 'xs') ...[
          // Optional: skip label for very small
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ],
    );
  }
}
