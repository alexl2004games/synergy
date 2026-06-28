import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/analytics_provider.dart';
import '../../../checkin/domain/user_checkin.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/providers/task_views_provider.dart';
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final checkinsAsync = ref.watch(checkinsProvider);
    final tasksAsync = ref.watch(allTasksProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/settings');
          },
        ),
        title: Text(l10n.analyticsTab),
      ),
      body: checkinsAsync.when(
        data: (checkins) => tasksAsync.when(
          data: (tasks) => _AnalyticsContent(
            checkins: checkins,
            tasks: tasks,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('$error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
      ),
    );
  }
}
class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({required this.checkins, required this.tasks});
  final List<UserCheckin> checkins;
  final List<Task> tasks;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trend = _buildTrendSeries(checkins);
    final scatter = _buildScatterSeries(tasks);
    final streakDays = _currentStreak(tasks);
    final hasTrendData = trend.mood.isNotEmpty || trend.productivity.isNotEmpty;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: l10n.analyticsMoodProductivityTitle,
          child: SizedBox(
            height: 240,
            child: Column(
              children: [
                Expanded(
                  child: !hasTrendData
                      ? _EmptyChartState(message: l10n.analyticsNoData)
                      : LineChart(_buildTrendChartData(trend)),
                ),
                if (hasTrendData)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 6),
                        Text(l10n.checkinMood, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 20),
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 6),
                        Text(l10n.checkinProductivity, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: l10n.analyticsPlanningAccuracyTitle,
          subtitle: l10n.analyticsPlanningAccuracyBody,
          child: SizedBox(
            height: 260,
            child: scatter.isEmpty
                ? _EmptyChartState(message: l10n.analyticsNoData)
                : _ScatterAccuracyChart(spots: scatter),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: l10n.analyticsStreakTitle,
          child: _StreakCard(
            streakDays: streakDays,
            suffix: l10n.analyticsStreakSuffix,
            body: l10n.analyticsStreakBody,
          ),
        ),
      ],
    );
  }
}
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
class _EmptyChartState extends StatelessWidget {
  const _EmptyChartState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
  }
}
class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.streakDays,
    required this.suffix,
    required this.body,
  });
  final int streakDays;
  final String suffix;
  final String body;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streakDays',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                suffix,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.local_fire_department,
          size: 56,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
class _ScatterAccuracyChart extends StatelessWidget {
  const _ScatterAccuracyChart({required this.spots});
  final List<FlSpot> spots;
  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(
      60.0,
      spots.fold<double>(
        0.0,
        (max, spot) => math.max(max, math.max(spot.x, spot.y)),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        ScatterChart(
          ScatterChartData(
            minX: 0,
            maxX: maxValue,
            minY: 0,
            maxY: maxValue,
            scatterSpots: spots
                .map(
                  (spot) => ScatterSpot(
                    spot.x,
                    spot.y,
                    dotPainter: FlDotCirclePainter(
                      radius: 4,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
                .toList(growable: false),
            scatterTouchData: ScatterTouchData(enabled: false),
            gridData: const FlGridData(),
            borderData: FlBorderData(show: true),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(),
              rightTitles: AxisTitles(),
              topTitles: AxisTitles(),
              bottomTitles: AxisTitles(),
            ),
          ),
        ),
        IgnorePointer(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: maxValue,
              minY: 0,
              maxY: maxValue,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot.zero,
                    FlSpot(maxValue, maxValue),
                  ],
                  color: Theme.of(context).colorScheme.outline,
                  dotData: const FlDotData(show: false),
                ),
              ],
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(),
                rightTitles: AxisTitles(),
                topTitles: AxisTitles(),
                bottomTitles: AxisTitles(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
({List<FlSpot> mood, List<FlSpot> productivity}) _buildTrendSeries(
  List<UserCheckin> checkins,
) {
  final today = DateUtils.dateOnly(DateTime.now());
  final start = today.subtract(const Duration(days: 29));
  final recent = checkins.where((checkin) {
    final date = DateUtils.dateOnly(checkin.date);
    return !date.isBefore(start) && !date.isAfter(today);
  }).toList(growable: false)
    ..sort((left, right) => left.date.compareTo(right.date));
  final moodSpots = <FlSpot>[];
  final productivitySpots = <FlSpot>[];
  for (final checkin in recent) {
    final date = DateUtils.dateOnly(checkin.date);
    final dayIndex = date.difference(start).inDays.toDouble();
    moodSpots.add(FlSpot(dayIndex, checkin.moodScore.toDouble()));
    productivitySpots.add(FlSpot(dayIndex, checkin.productivity.toDouble()));
  }
  return (mood: moodSpots, productivity: productivitySpots);
}
LineChartData _buildTrendChartData(
  ({List<FlSpot> mood, List<FlSpot> productivity}) trend,
) {
  return LineChartData(
    minX: 0,
    maxX: 29,
    minY: 0,
    maxY: 5,
    borderData: FlBorderData(show: true),
    titlesData: const FlTitlesData(
      leftTitles: AxisTitles(),
      rightTitles: AxisTitles(),
      topTitles: AxisTitles(),
      bottomTitles: AxisTitles(),
    ),
    lineBarsData: [
      LineChartBarData(
        spots: trend.mood,
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
      ),
      LineChartBarData(
        spots: trend.productivity,
        isCurved: true,
        color: Colors.orange,
        barWidth: 3,
      ),
    ],
  );
}
List<FlSpot> _buildScatterSeries(List<Task> tasks) {
  return tasks
      .where(
        (task) => task.status == TaskStatus.completed && task.actualMin != null,
      )
      .toList(growable: false)
      .reversed
      .take(50)
      .map((task) => FlSpot(task.estMin.toDouble(), task.actualMin!.toDouble()))
      .toList(growable: false);
}
int _currentStreak(List<Task> tasks) {
  final completedDays = tasks
      .where((task) => task.status == TaskStatus.completed)
      .map((task) => _dateKey(task.completedAt ?? task.updatedAt))
      .toSet();
  var streak = 0;
  var cursor = DateUtils.dateOnly(DateTime.now());
  while (completedDays.contains(_dateKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
int _dateKey(DateTime date) {
  final normalized = DateUtils.dateOnly(date);
  return normalized.year * 10000 + normalized.month * 100 + normalized.day;
}
