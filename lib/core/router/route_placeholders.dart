import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_localizations.dart';
import '../widgets/liquid_background.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/lock_screen.dart';
import '../../features/tasks/presentation/screens/task_details_screen.dart';
class RoutePlaceholderScreen extends StatelessWidget {
  const RoutePlaceholderScreen({
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });
  final String title;
  final String? body;
  final String? actionLabel;
  final Future<void> Function()? onAction;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (body != null) ...[
                const SizedBox(height: 12),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed:
                      onAction == null ? null : () => unawaited(onAction!()),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
class LockRouteScreen extends StatelessWidget {
  const LockRouteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const LockScreen();
  }
}
class OnboardingRouteScreen extends ConsumerWidget {
  const OnboardingRouteScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const OnboardingScreen();
  }
}
class TaskDetailsRouteScreen extends StatelessWidget {
  const TaskDetailsRouteScreen({required this.taskId, super.key});
  final String taskId;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayStyle = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Positioned.fill(child: LiquidBackground()),
            SafeArea(child: TaskDetailsScreen(taskId: taskId)),
          ],
        ),
      ),
    );
  }
}
class CheckInRouteScreen extends StatelessWidget {
  const CheckInRouteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkinTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.checkinTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
