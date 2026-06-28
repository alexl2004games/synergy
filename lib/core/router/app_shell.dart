import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';
import '../../features/scheduling/application/morning_proposal_notifier.dart';
import '../../features/scheduling/presentation/screens/morning_plan_screen.dart';
import '../../features/scheduling/presentation/screens/morning_settings_screen.dart';
import '../../features/tasks/presentation/providers/tasks_provider.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/glass_container.dart';
import '../widgets/liquid_background.dart';
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;
  void _selectTab(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = <_ShellDestination>[
      _ShellDestination(icon: Icons.today, label: l10n.todayTab),
      _ShellDestination(icon: Icons.inbox_outlined, label: l10n.inboxTab),
      _ShellDestination(
        icon: Icons.watch_later_outlined,
        label: l10n.upcomingTab,
      ),
      _ShellDestination(
        icon: Icons.calendar_month_outlined,
        label: l10n.calendarTab,
      ),
      _ShellDestination(
        icon: Icons.grid_view_rounded,
        label: l10n.spacesTab,
      ),
      _ShellDestination(icon: Icons.settings_outlined, label: l10n.settingsTab),
    ];
    ref.listen(morningProposalProvider, (previous, next) {
      if (!context.mounted) {
        return;
      }
      next.whenData((proposal) {
        if (proposal != null && proposal.hasAnything) {
          unawaited(
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (_) => MorningPlanScreen(
                proposal: proposal,
                onAcceptAll: () {
                  unawaited(
                    ref.read(morningProposalProvider.notifier).apply(
                          proposal,
                          DateTime.now(),
                        ),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                onCustomize: () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    unawaited(
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MorningSettingsScreen(
                            proposal: proposal,
                            onApply: (filteredProposal) {
                              unawaited(
                                ref
                                    .read(morningProposalProvider.notifier)
                                    .apply(
                                      filteredProposal,
                                      DateTime.now(),
                                    ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
      });
    });
    final showConfetti = ref.watch<bool>(confettiProvider);
    final isMorningRecalculating = ref.watch(morningProposalProvider).isLoading;
    final scaffold = Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            const _OpenSearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            const _OpenSearchIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenSearchIntent: CallbackAction<_OpenSearchIntent>(
            onInvoke: (_) {
              context.push('/search');
              return null;
            },
          ),
        },
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: navigationShell,
          bottomNavigationBar: Platform.isMacOS
              ? null
              : SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: GlassContainer(
                      borderRadius: 32,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16,),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(destinations.length, (index) {
                          final isSelected =
                              navigationShell.currentIndex == index;
                          final dest = destinations[index];
                          final theme = Theme.of(context);
                          final color = isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5);
                          return IconButton(
                            iconSize: 28,
                            icon: Icon(dest.icon, color: color),
                            onPressed: () => _selectTab(index),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
    final Widget mainScaffold = Platform.isMacOS
        ? Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
                  const _OpenSearchIntent(),
              LogicalKeySet(
                LogicalKeyboardKey.control,
                LogicalKeyboardKey.keyK,
              ): const _OpenSearchIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                _OpenSearchIntent: CallbackAction<_OpenSearchIntent>(
                  onInvoke: (_) {
                    context.push('/search');
                    return null;
                  },
                ),
              },
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Row(
                    children: [
                      NavigationRail(
                        backgroundColor: Colors.transparent,
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: _selectTab,
                        labelType: NavigationRailLabelType.all,
                        destinations: destinations
                            .map(
                              (destination) => NavigationRailDestination(
                                icon: Icon(destination.icon),
                                label: Text(destination.label),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: navigationShell,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : scaffold;
    final Widget content = Stack(
      children: [
        const Positioned.fill(child: LiquidBackground()),
        Positioned.fill(child: mainScaffold),
      ],
    );
    final theme = Theme.of(context);
    final overlayStyle = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Stack(
        children: [
          content,
          if (showConfetti) const Positioned.fill(child: ConfettiOverlay()),
          if (isMorningRecalculating)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Center(
                    child: Card(
                      elevation: 12,
                      color:
                          Theme.of(context).cardColor.withValues(alpha: 0.88),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'ИИ настраивает ваш день...',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Балансировка и оптимизация планов',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
class _ShellDestination {
  const _ShellDestination({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
class _OpenSearchIntent extends Intent {
  const _OpenSearchIntent();
}
