import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/widgets/task_card.dart';
import '../application/task_search_provider.dart';
import 'dart:async';
import '../../tasks/application/task_repository_provider.dart';
import '../../tasks/data/drift_task_repository.dart';
import '../../../core/notifications/application/notification_providers.dart';
import '../../recurrence/application/recurrence_engine_provider.dart';
import '../../recurrence/presentation/delete_recurrence_dialog.dart';
import '../../scheduling/application/task_scheduling_refresh_trigger.dart';
class TaskSearchScreen extends ConsumerStatefulWidget {
  const TaskSearchScreen({super.key});
  @override
  ConsumerState<TaskSearchScreen> createState() => _TaskSearchScreenState();
}
class _TaskSearchScreenState extends ConsumerState<TaskSearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final FocusNode _keyboardFocusNode;
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = -1;
  final Map<int, GlobalKey> _resultKeys = {};
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _keyboardFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        _keyboardFocusNode.requestFocus();
      }
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }
  void _setQuery(String value) {
    ref.read(taskSearchQueryProvider.notifier).query = value;
    setState(() => _selectedIndex = -1);
  }
  void _moveSelection(int delta, int max) {
    if (max <= 0) return;
    setState(() {
      if (_selectedIndex < 0) {
        _selectedIndex = delta > 0 ? 0 : max - 1;
      } else {
        _selectedIndex = (_selectedIndex + delta) % max;
        if (_selectedIndex < 0) _selectedIndex += max;
      }
    });
    final key = _resultKeys[_selectedIndex];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 150),
        alignment: 0.5,
      );
    } else {
      _scrollController.animateTo(
        (_selectedIndex * 80).toDouble(),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(taskSearchQueryProvider);
    final results = ref.watch(taskSearchResultsProvider);
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.escape) {
            context.pop();
            return;
          }
          if (key == LogicalKeyboardKey.arrowDown) {
            _moveSelection(1, results.length);
            return;
          }
          if (key == LogicalKeyboardKey.arrowUp) {
            _moveSelection(-1, results.length);
            return;
          }
          if (key == LogicalKeyboardKey.enter) {
            if (_selectedIndex >= 0 && _selectedIndex < results.length) {
              final task = results[_selectedIndex];
              context.push('/task/${task.id}');
            }
            return;
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
          ),
          title: Text(l10n.searchTitle),
          actions: [
            if (query.isNotEmpty)
              IconButton(
                tooltip: l10n.searchClearButton,
                onPressed: () {
                  _controller.clear();
                  _setQuery('');
                  _focusNode.requestFocus();
                },
                icon: const Icon(Icons.clear),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autocorrect: false,
                  onChanged: _setQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              if (query.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.searchRecentTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${l10n.searchResultsTitle} ${results.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              Expanded(
                child: results.isEmpty
                    ? _EmptySearchState(
                        title: query.isEmpty
                            ? l10n.searchEmptyTitle
                            : l10n.searchNoResultsTitle,
                        body: query.isEmpty
                            ? l10n.searchEmptyBody
                            : l10n.searchNoResultsBody,
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemBuilder: (context, index) {
                          final task = results[index];
                          final key =
                              _resultKeys.putIfAbsent(index, GlobalKey.new);
                          return _SearchResultItem(
                            key: key,
                            task: task,
                            selected: index == _selectedIndex,
                            onTap: () => context.push('/task/${task.id}'),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemCount: results.length,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _SearchResultItem extends ConsumerWidget {
  const _SearchResultItem({
    required this.task,
    required this.onTap,
    this.selected = false,
    super.key,
  });
  final Task task;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: selected
          ? BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Dismissible(
        key: ValueKey(task.id),
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.check_circle_outline, color: Colors.green),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.red),
        ),
        confirmDismiss: (direction) async {
          switch (direction) {
            case DismissDirection.startToEnd:
              await ref.read(taskRepositoryProvider).update(
                    task.copyWith(
                      status: TaskStatus.completed,
                      completedAt: DateTime.now(),
                    ),
                  );
              await ref
                  .read(notificationServiceProvider)
                  .cancelTaskReminder(task.id);
              return true;
            case DismissDirection.endToStart:
              final recurring = (task.recurrenceRule?.isNotEmpty ?? false) ||
                  task.parentTaskId != null;
              if (!recurring) {
                await ref.read(taskRepositoryProvider).delete(task.id);
                await ref
                    .read(notificationServiceProvider)
                    .cancelTaskReminder(task.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.taskDeletedSnack),
                      action: SnackBarAction(
                        label: l10n.undoButton,
                        onPressed: () {
                          unawaited(
                            ref.read(taskRepositoryProvider).save(task),
                          );
                          unawaited(
                            ref
                                .read(notificationServiceProvider)
                                .scheduleTaskReminder(task, 15),
                          );
                        },
                      ),
                    ),
                  );
                }
                return true;
              }
              final choice = await showDialog<DeleteRecurrenceOption>(
                context: context,
                builder: (_) => const DeleteRecurrenceDialog(),
              );
              if (choice == null) {
                return false;
              }
              final recurrenceEngine = ref.read(recurrenceEngineProvider);
              final driftTask = task.toDrift();
              switch (choice) {
                case DeleteRecurrenceOption.instance:
                  await recurrenceEngine.deleteAllExceptInstance(driftTask);
                case DeleteRecurrenceOption.allFuture:
                  await recurrenceEngine.deleteAllFuture(driftTask);
                case DeleteRecurrenceOption.all:
                  await recurrenceEngine.deleteSeries(driftTask);
              }
              ref.read(taskSchedulingRefreshTriggerProvider).schedule();
              await ref
                  .read(notificationServiceProvider)
                  .cancelTaskReminder(task.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.taskDeletedSnack),
                  ),
                );
              }
              return true;
            case DismissDirection.horizontal:
            case DismissDirection.vertical:
            case DismissDirection.up:
            case DismissDirection.down:
            case DismissDirection.none:
              return false;
          }
        },
        child: TaskCard(task: task, onTap: onTap),
      ),
    );
  }
}
class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.title, required this.body});
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
              Icons.search,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
