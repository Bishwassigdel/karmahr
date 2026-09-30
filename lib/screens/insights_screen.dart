// Charts dashboard — turns numbers that were previously just sitting in
// stat boxes into actual visualizations. Three sections:
//  1. Leave usage this fiscal year (bar chart) — real data, from the
//     same LeaveBalanceState/leave_policy engine leave_balances_screen
//     uses, not a separate demo dataset.
//  2. Attendance this week (line chart) — demo data (no real daily
//     attendance history exists yet; AttendanceState only tracks
//     "today"), clearly labeled as such.
//  3. Kudos leaderboard — real data, aggregated from KudosState's posts.
//
// Frontend-only: sections 1 and 3 already reflect real Provider state,
// so wiring in a backend later only changes where LeaveState/KudosState
// get their data from, not this screen.

import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../domain/nepal/fiscal_year.dart';
import '../state/kudos_state.dart';
import '../state/leave_balance_state.dart';
import '../state/leave_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/staggered_entrance.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaveRequests = context.watch<LeaveState>().requests;
    final balances = context.watch<LeaveBalanceState>().balancesFor(
      leaveRequests,
    );
    final kudosPosts = context.watch<KudosState>().posts;
    final surfaceSecondary = AppColors.surfaceSecondary.resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Insights')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StaggeredEntrance(
              index: 0,
              child: _SectionCard(
                title: 'Leave Used This Fiscal Year',
                subtitle:
                    'FY ${NepaliFiscalYear.current().label} · from your '
                    'real leave balances',
                background: surfaceSecondary,
                child: _LeaveUsageChart(balances: balances),
              ),
            ),
            const SizedBox(height: 16),
            StaggeredEntrance(
              index: 1,
              child: _SectionCard(
                title: 'Attendance This Week',
                subtitle:
                    'Demo data — no attendance history is tracked yet, '
                    'only today\'s check-in/out',
                background: surfaceSecondary,
                child: const _AttendanceTrendChart(),
              ),
            ),
            const SizedBox(height: 16),
            StaggeredEntrance(
              index: 2,
              child: _SectionCard(
                title: 'Kudos Leaderboard',
                subtitle: 'Total points received, from real Kudos Wall posts',
                background: surfaceSecondary,
                child: _KudosLeaderboard(
                  posts: kudosPosts,
                  subtleTextColor: subtleTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color background;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.background,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.5, color: subtleTextColor),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ============================================================
// 1. LEAVE USAGE — bar chart, one bar per leave type, real data.
// ============================================================
class _LeaveUsageChart extends StatelessWidget {
  final List<LeaveBalance> balances;

  const _LeaveUsageChart({required this.balances});

  @override
  Widget build(BuildContext context) {
    // Unpaid Leave has an infinite entitlement (see leave_policy.dart) —
    // that's meaningless on a bar chart's y-axis, so it's excluded here.
    // Substitute Leave defaults to a zero grant (earned per-instance,
    // not tracked as a pool) — also excluded, nothing to chart.
    final chartable = balances
        .where((b) => b.entitled.isFinite && b.entitled > 0)
        .toList();

    if (chartable.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No leave data to chart yet.')),
      );
    }

    final maxEntitled = chartable
        .map((b) => b.entitled)
        .reduce((a, b) => a > b ? a : b);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);
    final karmaRed = AppColors.karmaRed;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxEntitled * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final balance = chartable[group.x.toInt()];
                return BarTooltipItem(
                  '${balance.type}\n',
                  const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '${_fmt(balance.used)} used of '
                          '${_fmt(balance.entitled)}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  _fmt(value),
                  style: TextStyle(fontSize: 10, color: subtleTextColor),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= chartable.length) {
                    return const SizedBox.shrink();
                  }
                  // Short label — the full leave type name is in the
                  // tooltip on tap, this just needs to fit under a bar.
                  final label = chartable[index].type
                      .replaceAll(' Leave', '')
                      .replaceAll('Maternity Care', 'Mat. Care');
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 9, color: subtleTextColor),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < chartable.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: chartable[i].entitled,
                    color: CupertinoColors.systemGrey4.resolveFrom(context),
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: chartable[i].used,
                    color: karmaRed,
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

// ============================================================
// 2. ATTENDANCE TREND — line chart, DEMO data (see class doc above).
// ============================================================
class _AttendanceTrendChart extends StatelessWidget {
  const _AttendanceTrendChart();

  // Sun–Fri (Nepal's work week; Saturday is the weekly holiday, so it's
  // deliberately not one of the 6 points here) hours-worked demo values.
  static const _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static const _hoursWorked = [8.0, 7.5, 8.0, 8.5, 6.0, 8.0];

  @override
  Widget build(BuildContext context) {
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);
    final karmaRed = AppColors.karmaRed;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: CupertinoColors.systemGrey5.resolveFrom(context),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
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
                interval: 2,
                reservedSize: 24,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: subtleTextColor),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _dayLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _dayLabels[index],
                      style: TextStyle(fontSize: 10, color: subtleTextColor),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                return LineTooltipItem(
                  '${_dayLabels[spot.x.toInt()]}\n${spot.y} hrs',
                  const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < _hoursWorked.length; i++)
                  FlSpot(i.toDouble(), _hoursWorked[i]),
              ],
              isCurved: true,
              color: karmaRed,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: karmaRed.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 3. KUDOS LEADERBOARD — ranked list, real data from KudosState.
// ============================================================
class _KudosLeaderboard extends StatelessWidget {
  final List<KudosPost> posts;
  final Color subtleTextColor;

  const _KudosLeaderboard({required this.posts, required this.subtleTextColor});

  @override
  Widget build(BuildContext context) {
    // Aggregate points received, per person — a KudosPost with no
    // points still counts toward being recognized, so give every
    // recipient at least an entry even at 0 points (via fold's default).
    final totals = <String, int>{};
    for (final post in posts) {
      totals[post.toName] = (totals[post.toName] ?? 0) + post.points;
    }

    final ranked = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.take(5).toList();

    if (top.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No kudos given yet.')),
      );
    }

    final maxPoints = top.first.value == 0 ? 1 : top.first.value;

    return Column(
      children: [
        for (var i = 0; i < top.length; i++) ...[
          _LeaderboardRow(
            rank: i + 1,
            name: top[i].key,
            points: top[i].value,
            fraction: top[i].value / maxPoints,
            subtleTextColor: subtleTextColor,
          ),
          if (i != top.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final double fraction;
  final Color subtleTextColor;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.points,
    required this.fraction,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = switch (rank) {
      1 => CupertinoColors.systemYellow.resolveFrom(context),
      2 => CupertinoColors.systemGrey.resolveFrom(context),
      3 => CupertinoColors.systemOrange.resolveFrom(context),
      _ => subtleTextColor,
    };
    final track = CupertinoColors.systemGrey5.resolveFrom(context);

    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '#$rank',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 5,
                  child: Stack(
                    children: [
                      Container(color: track),
                      FractionallySizedBox(
                        widthFactor: fraction.clamp(0.0, 1.0),
                        child: Container(color: AppColors.karmaRed),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$points pts',
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
