// 1. IMPORTS
import 'package:flutter/cupertino.dart';

import '../l10n/l10n.dart';
import 'package:nepali_utils/nepali_utils.dart';
import '../domain/nepal/bs_dates.dart';

import '../theme/app_colors.dart';
import '../data/calendar_data.dart';

// 2. HOLIDAY CALENDAR SCREEN
class HolidayCalendarScreen extends StatefulWidget {
  const HolidayCalendarScreen({super.key});

  @override
  State<HolidayCalendarScreen> createState() => _HolidayCalendarScreenState();
}

class _HolidayCalendarScreenState extends State<HolidayCalendarScreen> {
  // The BS month currently on screen (day is always 1 — only
  // year/month matter here).
  late NepaliDateTime _displayedMonth;

  // Currently selected day within that month.
  late int _selectedDay;

  // Which marker types are currently shown — all on by default.
  final Set<MarkerType> _activeFilters = MarkerType.values.toSet();

  @override
  void initState() {
    super.initState();
    final today = bsToday();
    _displayedMonth = NepaliDateTime(today.year, today.month, 1);
    _selectedDay = today.day;
  }

  @override
  Widget build(BuildContext context) {
    // CupertinoDynamicColor values must be resolved against the current
    // context before use in a plain Container/Text — otherwise they
    // silently always render their light-mode value, even in Dark Mode.
    final cardBackground = CupertinoColors.systemBackground.resolveFrom(
      context,
    );
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final borderColor = CupertinoColors.systemGrey5.resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    final markerColors = <MarkerType, Color>{
      MarkerType.governmentHoliday: AppColors.karmaRed,
      MarkerType.companyHoliday: CupertinoColors.systemPurple.resolveFrom(
        context,
      ),
      MarkerType.myLeave: CupertinoColors.systemYellow.resolveFrom(context),
      MarkerType.present: CupertinoColors.systemGreen.resolveFrom(context),
      MarkerType.companyEvent: CupertinoColors.systemIndigo.resolveFrom(
        context,
      ),
    };

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('HR Calendar')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            const SizedBox(height: 20),

            _buildMonthHeader(subtleTextColor),

            const SizedBox(height: 20),

            _buildCalendarCard(cardBackground, labelColor, markerColors),

            const SizedBox(height: 20),

            _buildLegend(subtleTextColor, markerColors),

            const SizedBox(height: 16),

            _buildFilters(cardBackground, borderColor, markerColors),

            const SizedBox(height: 24),

            _buildHighlights(
              cardBackground,
              borderColor,
              subtleTextColor,
              markerColors,
            ),
          ],
        ),
      ),
    );
  }

  // 3. MONTH HEADER
  Widget _buildMonthHeader(Color subtleTextColor) {
    final bsLabel =
        '${NepaliDateFormat('MMMMM', Language.nepali).format(_displayedMonth)} '
        '${NepaliDateFormat('y', Language.nepali).format(_displayedMonth)}';

    final adDate = _displayedMonth.toDateTime();
    final adLabel = '${adMonths[adDate.month - 1]} ${adDate.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _goToPreviousMonth,
            child: Icon(CupertinoIcons.chevron_left, semanticLabel: context.l10n.a11yPreviousMonth, size: 22),
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  bsLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  adLabel,
                  style: TextStyle(fontSize: 14, color: subtleTextColor),
                ),
              ],
            ),
          ),

          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _goToNextMonth,
            child: Icon(CupertinoIcons.chevron_right, semanticLabel: context.l10n.a11yNextMonth, size: 22),
          ),
        ],
      ),
    );
  }

  // 4. CALENDAR CARD
  Widget _buildCalendarCard(
    Color cardBackground,
    Color labelColor,
    Map<MarkerType, Color> markerColors,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWeekdayHeader(labelColor),

          const SizedBox(height: 12),

          _buildCalendarGrid(labelColor, markerColors),
        ],
      ),
    );
  }

  // 5. WEEKDAY HEADER
  Widget _buildWeekdayHeader(Color labelColor) {
    const weekdays = ['आइत', 'सोम', 'मंगल', 'बुध', 'बिहि', 'शुक्र', 'शनि'];

    return Row(
      children: List.generate(weekdays.length, (index) {
        final isSaturday = index == 6;
        return Expanded(
          child: Center(
            child: Text(
              weekdays[index],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSaturday
                    ? AppColors.karmaRed
                    : labelColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      }),
    );
  }

  // 6. CALENDAR GRID
  Widget _buildCalendarGrid(
    Color labelColor,
    Map<MarkerType, Color> markerColors,
  ) {
    final totalDays = _displayedMonth.totalDays;
    // NepaliDateTime.weekday: 1=Sunday ... 7=Saturday.
    final firstWeekdayOffset = _displayedMonth.weekday - 1;
    final totalCells = firstWeekdayOffset + totalDays;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 4,
        childAspectRatio: 0.9,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < firstWeekdayOffset) {
          return const SizedBox.shrink();
        }

        final day = index - firstWeekdayOffset + 1;
        final isSaturday = index % 7 == 6;
        final marker =
            demoMarkers[markerKey(
              _displayedMonth.year,
              _displayedMonth.month,
              day,
            )];
        final visibleMarker =
            marker != null && _activeFilters.contains(marker.type)
            ? marker
            : null;
        final isSelected = _selectedDay == day;

        return GestureDetector(
          onTap: () => _selectDay(day, visibleMarker),
          child: _buildDayCell(
            day: day,
            marker: visibleMarker,
            isSaturday: isSaturday,
            isSelected: isSelected,
            labelColor: labelColor,
            markerColors: markerColors,
          ),
        );
      },
    );
  }

  // 7. DAY CELL
  Widget _buildDayCell({
    required int day,
    required DayMarker? marker,
    required bool isSaturday,
    required bool isSelected,
    required Color labelColor,
    required Map<MarkerType, Color> markerColors,
  }) {
    final dotColor = marker == null ? null : markerColors[marker.type];
    final numberColor = isSelected
        ? CupertinoColors.white
        : (isSaturday ? AppColors.karmaRed : labelColor);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.karmaRed : CupertinoColors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      // The number + marker dot scale down to fit the cell instead of
      // overflowing it on narrow phones or at large text sizes.
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                NepaliUnicode.convert('$day'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: numberColor,
                ),
              ),

              const SizedBox(height: 5),

              if (dotColor != null)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? CupertinoColors.white : dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  // 8. LEGEND
  Widget _buildLegend(
    Color subtleTextColor,
    Map<MarkerType, Color> markerColors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          for (final type in MarkerType.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: markerColors[type],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    labelFor(type),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: subtleTextColor),
                  ),
                ),
              ],
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.karmaRed,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Selected',
                style: TextStyle(fontSize: 12.5, color: subtleTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 9. FILTERS
  Widget _buildFilters(
    Color cardBackground,
    Color borderColor,
    Map<MarkerType, Color> markerColors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: MarkerType.values.map((type) {
          final isActive = _activeFilters.contains(type);
          final color = markerColors[type]!;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isActive) {
                  _activeFilters.remove(type);
                } else {
                  _activeFilters.add(type);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? color.withValues(alpha: 0.12)
                    : cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? color.withValues(alpha: 0.4) : borderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconFor(type),
                    size: 13,
                    color: isActive ? color : color.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      labelFor(type),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isActive ? color : color.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 10. THIS MONTH'S HIGHLIGHTS
  Widget _buildHighlights(
    Color cardBackground,
    Color borderColor,
    Color subtleTextColor,
    Map<MarkerType, Color> markerColors,
  ) {
    final entries = <MapEntry<int, DayMarker>>[];
    for (var day = 1; day <= _displayedMonth.totalDays; day++) {
      final marker =
          demoMarkers[markerKey(
            _displayedMonth.year,
            _displayedMonth.month,
            day,
          )];
      if (marker != null && _activeFilters.contains(marker.type)) {
        entries.add(MapEntry(day, marker));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "This Month's Highlights",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),

          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Nothing to show for this filter this month.',
                style: TextStyle(fontSize: 13.5, color: subtleTextColor),
              ),
            )
          else
            ...entries.map((entry) {
              return _buildHighlightCard(
                day: entry.key,
                marker: entry.value,
                cardBackground: cardBackground,
                borderColor: borderColor,
                markerColors: markerColors,
              );
            }),
        ],
      ),
    );
  }

  // 11. HIGHLIGHT CARD
  Widget _buildHighlightCard({
    required int day,
    required DayMarker marker,
    required Color cardBackground,
    required Color borderColor,
    required Map<MarkerType, Color> markerColors,
  }) {
    final color = markerColors[marker.type]!;

    return GestureDetector(
      onTap: () => _showMarkerDetails(day, marker),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  NepaliUnicode.convert('$day'),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    marker.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      labelFor(marker.type),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              CupertinoIcons.chevron_right, semanticLabel: context.l10n.a11yNextMonth,
              size: 18,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  // 12. SELECT DAY
  void _selectDay(int day, DayMarker? marker) {
    setState(() {
      _selectedDay = day;
    });

    if (marker != null) {
      _showMarkerDetails(day, marker);
    }
  }

  // 13. DETAIL BOTTOM SHEET
  void _showMarkerDetails(int day, DayMarker marker) {
    final bsDate = NepaliDateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      day,
    );
    final adDate = bsDate.toDateTime();
    final bsLabel =
        '${NepaliDateFormat('MMMMM', Language.nepali).format(bsDate)} '
        '${NepaliUnicode.convert('$day')}, '
        '${NepaliDateFormat('y', Language.nepali).format(bsDate)}';
    final adLabel =
        '${adMonths[adDate.month - 1]} ${adDate.day}, ${adDate.year}';

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            marker.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          message: Text(
            '$bsLabel  ($adLabel)\n\n'
            '${labelFor(marker.type)}\n\n'
            '${marker.description}',
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  // 14. MONTH NAVIGATION
  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = _displayedMonth.month == 1
          ? NepaliDateTime(_displayedMonth.year - 1, 12, 1)
          : NepaliDateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
      _selectedDay = 1;
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = _displayedMonth.month == 12
          ? NepaliDateTime(_displayedMonth.year + 1, 1, 1)
          : NepaliDateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
      _selectedDay = 1;
    });
  }
}
