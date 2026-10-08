import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../../data/company_demo.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/status_badge.dart';

Color progressColor(ProgressStatus s) => switch (s) {
  ProgressStatus.onTrack => CupertinoColors.activeGreen,
  ProgressStatus.watch => CupertinoColors.systemOrange,
  ProgressStatus.behind => CupertinoColors.destructiveRed,
};

String progressLabel(AppLocalizations l10n, ProgressStatus s) => switch (s) {
  ProgressStatus.onTrack => l10n.ownerStatusOnTrack,
  ProgressStatus.watch => l10n.ownerStatusWatch,
  ProgressStatus.behind => l10n.ownerStatusBehind,
};

/// "On track", "Watch" or "Behind" as a coloured pill.
class ProgressBadge extends StatelessWidget {
  final ProgressStatus status;

  const ProgressBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: progressLabel(context.l10n, status),
      color: progressColor(status),
    );
  }
}

/// A label, a 0 to 100 value, and a bar showing it.
class PercentBar extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  /// What to print beside the label; "$value%" when null.
  final String? valueText;

  const PercentBar({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    final fill = color ?? AppColors.karmaRed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                valueText ?? '$value%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: CupertinoColors.systemGrey5.resolveFrom(context),
                ),
                FractionallySizedBox(
                  widthFactor: (value / 100).clamp(0.0, 1.0),
                  child: Container(height: 6, color: fill),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple line chart of [values], oldest first, labelled by [labels].
/// [format] writes a value on the vertical axis (for example a crore
/// figure).
class TrendChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String Function(double) format;
  final double height;

  const TrendChart({
    super.key,
    required this.values,
    required this.labels,
    required this.format,
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    if (values.length < 2) return SizedBox(height: height);

    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    // Pad the range so a flat line isn't pressed against the edge.
    final pad = (hi - lo).abs() < 1e-9
        ? (hi.abs() * 0.1 + 1)
        : (hi - lo) * 0.15;
    final minY = lo - pad;
    final maxY = hi + pad;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: CupertinoColors.systemGrey5.resolveFrom(context),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                interval: (maxY - minY) / 3,
                getTitlesWidget: (value, meta) {
                  // Skip the very ends, which only add clutter.
                  if (value <= minY + 1e-6 || value >= maxY - 1e-6) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    format(value),
                    style: TextStyle(fontSize: 10, color: subtle),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  // Every other month, so the labels never collide.
                  if (i < 0 || i >= labels.length || i % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: TextStyle(fontSize: 10, color: subtle),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              curveSmoothness: 0.25,
              color: AppColors.karmaRed,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.karmaRed.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
