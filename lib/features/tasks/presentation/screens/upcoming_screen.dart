import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/task.dart';
import '../providers/task_views_provider.dart';
import '../widgets/task_card.dart';
class UpcomingScreen extends ConsumerStatefulWidget {
  const UpcomingScreen({super.key});
  @override
  ConsumerState<UpcomingScreen> createState() => _UpcomingScreenState();
}
class _UpcomingScreenState extends ConsumerState<UpcomingScreen> {
  static const int _centerPageIndex = 30;
  late final PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _centerPageIndex);
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = List<DateTime>.generate(
      61,
      (index) => DateUtils.dateOnly(
        DateTime.now().add(Duration(days: index - _centerPageIndex)),
      ),
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.upcomingTab),
        actions: [
          IconButton(
            tooltip: l10n.searchTitle,
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final tasksAsync = ref.watch(tasksByDayProvider(day));
          final dayTitle = '${DateFormat.EEEE(locale).format(day)}, '
              '${DateFormat.yMMMMd(locale).format(day)}';
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _EmptyState(
                          title: l10n.upcomingEmptyTitle,
                          body: l10n.upcomingEmptyBody,
                        ),
                      ),
                    ],
                  );
                }
                return _UpcomingDayView(
                  title: dayTitle,
                  tasks: tasks,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('$error')),
            ),
          );
        },
      ),
    );
  }
}
class _UpcomingDayView extends StatefulWidget {
  const _UpcomingDayView({required this.title, required this.tasks});
  final String title;
  final List<Task> tasks;
  @override
  State<_UpcomingDayView> createState() => _UpcomingDayViewState();
}
class _UpcomingDayViewState extends State<_UpcomingDayView> {
  bool _completedExpanded = false;
  @override
  Widget build(BuildContext context) {
    final pending = widget.tasks
        .where((t) => t.status != TaskStatus.completed)
        .toList(growable: false);
    final completed = widget.tasks
        .where((t) => t.status == TaskStatus.completed)
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ...pending.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == pending.length - 1 && completed.isEmpty
                        ? 0
                        : 12,
                  ),
                  child: TaskCard(
                    task: task,
                    onTap: () => context.push('/task/${task.id}'),
                  ),
                );
              }),
              if (completed.isNotEmpty) ...[
                if (pending.isNotEmpty) const SizedBox(height: 8),
                _CompletedSection(
                  tasks: completed,
                  isExpanded: _completedExpanded,
                  onExpandedChanged: (expanded) {
                    setState(() => _completedExpanded = expanded);
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
class _CompletedSection extends StatelessWidget {
  const _CompletedSection({
    required this.tasks,
    required this.isExpanded,
    required this.onExpandedChanged,
  });
  final List<Task> tasks;
  final bool isExpanded;
  final ValueChanged<bool> onExpandedChanged;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        '${AppLocalizations.of(context)!.taskCompleted} (${tasks.length})',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: onExpandedChanged,
      trailing: Icon(
        isExpanded ? Icons.expand_less : Icons.expand_more,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: tasks
          .map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Opacity(
                opacity: 0.6,
                child: TaskCard(
                  task: task,
                  onTap: () => context.push('/task/${task.id}'),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
