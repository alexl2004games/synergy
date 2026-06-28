import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/application/settings_providers.dart';
import '../../features/ai_engine/presentation/ai_command_sheet.dart';
import '../../features/tasks/presentation/widgets/task_form_sheet.dart';
import '../../features/tasks/presentation/providers/task_creation_controller.dart';
import '../../features/ai_engine/domain/llm_service.dart';
import 'glass_container.dart';
class FloatingActionDoubleButton extends ConsumerWidget {
  const FloatingActionDoubleButton({
    super.key,
    this.isToday = false,
    this.forceBypassLlm = false,
  });
  final bool isToday;
  final bool forceBypassLlm;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final experimentalEnabled = ref.watch(experimentalFeaturesNotifierProvider);
    final creationState = ref.watch(taskCreationControllerProvider);
    final isCreating = creationState.isLoading;
    ref.listen<AsyncValue<LLMTelemetry?>>(taskCreationControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next.hasValue && !next.hasError) {
        final telemetry = next.value;
        if (telemetry != null && ref.read(experimentalFeaturesNotifierProvider)) {
          final tpsStr = telemetry.tokensPerSecond.toStringAsFixed(1);
          final ms = telemetry.elapsedMs;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚡ Бэкенд: ${telemetry.backend} | $ms мс | ~$tpsStr t/s'),
            ),
          );
        }
      }
    });
    final capsuleBg = isDark ? 0.16 : 0.08;
    final capsuleBorder = isDark ? 0.22 : 0.14;
    return Semantics(
      label: 'AI and Task Creation Control Bar',
      child: Padding(
        padding: EdgeInsets.only(bottom: Platform.isMacOS ? 0 : 105),
        child: GlassContainer(
          borderRadius: 32,
          blur: 20,
          bgOpacity: capsuleBg,
          borderOpacity: capsuleBorder,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: isCreating
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6, right: 2),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Tooltip(
                message: 'Добавить задачу',
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isCreating ? 0.4 : 1.0,
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isCreating ? null : () {
                          TaskFormSheet.show(
                            context,
                            isToday: isToday,
                            forceBypassLlm: forceBypassLlm,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.add_rounded,
                            size: 26,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (experimentalEnabled) ...[
                Container(
                  width: 1.2,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.15),
                ),
                Tooltip(
                  message: 'Командный центр ИИ Синергия',
                  child: InkWell(
                    onTap: () {
                      AICommandSheet.show(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FFA3)
                                .withValues(alpha: isDark ? 0.35 : 0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: isDark ? 0.35 : 0.2),
                            blurRadius: 12,
                            spreadRadius: -1,
                          ),
                        ],
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00FFA3).withValues(alpha: 0.25),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: _AnimatedSynergyLogo(),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
class _AnimatedSynergyLogo extends StatefulWidget {
  const _AnimatedSynergyLogo();
  @override
  State<_AnimatedSynergyLogo> createState() => _AnimatedSynergyLogoState();
}
class _AnimatedSynergyLogoState extends State<_AnimatedSynergyLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'assets/images/synergy_icon.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
