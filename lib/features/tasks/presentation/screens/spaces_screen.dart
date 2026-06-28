import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/floating_action_double_button.dart';
import '../providers/spaces_provider.dart';
import '../widgets/task_swipe_item.dart';
class SpacesScreen extends ConsumerWidget {
  const SpacesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacesAsync = ref.watch(spacesProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.spacesTab),
        actions: [
          IconButton(
            tooltip: l10n.searchTitle,
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: spacesAsync.when(
        data: (spaces) {
          if (spaces.isEmpty) {
            return Center(
              child: Text(
                'Нет задач',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              final space = spaces[index];
              return _SpaceSection(space: space);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
      floatingActionButton: const FloatingActionDoubleButton(),
    );
  }
}
class _SpaceSection extends StatelessWidget {
  const _SpaceSection({required this.space});
  final SpaceGroup space;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(Icons.folder_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                space.tag,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  space.tasks.length.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...space.tasks.map(
          (task) => TaskSwipeItem(
            task: task,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
