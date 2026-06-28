import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_diary/core/localization/app_localizations.dart';
import '../../../core/widgets/glass_container.dart';
import '../../voice_input/application/voice_input_controller.dart';
import '../../voice_input/application/voice_input_providers.dart';
import '../application/ai_command_controller.dart';
class AICommandSheet extends ConsumerStatefulWidget {
  const AICommandSheet({super.key});
  static void show(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const AICommandSheet(),
        ),
      ),
    );
  }
  @override
  ConsumerState<AICommandSheet> createState() => _AICommandSheetState();
}
class _AICommandSheetState extends ConsumerState<AICommandSheet>
    with SingleTickerProviderStateMixin {
  final Logger _logger = Logger('AICommandSheet');
  late final TextEditingController _commandController;
  late final AnimationController _pulseController;
  @override
  void initState() {
    super.initState();
    _commandController = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }
  @override
  void dispose() {
    _commandController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  void _applyVoiceText(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _commandController.text = text.trim();
    });
  }
  Future<void> _submitCommand() async {
    final text = _commandController.text.trim();
    if (text.isEmpty) return;
    final result =
        await ref.read(aiCommandControllerProvider.notifier).execute(text);
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  Future<void> _startVoiceRecording() async {
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      await _showPermissionDialog();
      return;
    }
    try {
      await ref.read(voiceInputControllerProvider.notifier).startRecording();
    } on Object catch (e) {
      _logger.warning('Failed to start voice recording', e);
    }
  }
  Future<void> _stopVoiceRecording() async {
    try {
      await ref.read(voiceInputControllerProvider.notifier).stopAndTranscribe();
    } on Object catch (e) {
      _logger.warning('Error during stopAndTranscribe', e);
    }
  }
  Future<void> _showPermissionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.voicePermissionTitle),
        content: Text(l10n.voicePermissionBody),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await openAppSettings();
              } on MissingPluginException catch (_) {}
            },
            child: Text(l10n.openSettingsButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.closeButton),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = theme.textTheme;
    ref.listen<VoiceInputState>(voiceInputControllerProvider, (_, next) {
      switch (next) {
        case VoiceInputDone(:final text):
          _applyVoiceText(text);
        case VoiceInputError(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        case VoiceInputIdle():
        case VoiceInputRecording():
        case VoiceInputTranscribing():
      }
    });
    final voiceState = ref.watch(voiceInputControllerProvider);
    final commandState = ref.watch(aiCommandControllerProvider);
    final isLoading = commandState.isLoading;
    final containerBg = isDark ? 0.16 : 0.65;
    final containerBorder = isDark ? 0.22 : 0.35;
    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: GlassContainer(
              borderRadius: 32,
              blur: 24,
              bgOpacity: containerBg,
              borderOpacity: containerBorder,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF00FFA3),
                                Color(0xFF8B5CF6),
                              ],
                            ).createShader(bounds),
                            child: Icon(
                              Icons.psychology,
                              size: 28,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'ИИ Синергия',
                            style: textStyle.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commandController,
                          style: textStyle.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Спросите Синергию...',
                            hintStyle: textStyle.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            filled: true,
                            fillColor: (isDark ? Colors.black : Colors.white)
                                .withValues(alpha: 0.06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF00FFA3),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: _commandController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () => setState(() {
                                      _commandController.clear();
                                    }),
                                  )
                                : null,
                          ),
                          onSubmitted: (_) => unawaited(_submitCommand()),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _VoiceInputButton(
                        voiceState: voiceState,
                        onLongPressStart: (_) =>
                            unawaited(_startVoiceRecording()),
                        onLongPressEnd: (_) => unawaited(_stopVoiceRecording()),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _commandController.text.trim().isEmpty
                        ? null
                        : _submitCommand,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      shadowColor:
                          const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Выполнить команду',
                      style: textStyle.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: ColoredBox(
                color: (isDark ? Colors.black : Colors.white)
                    .withValues(alpha: 0.2),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        final val =
                            math.sin(_pulseController.value * 2 * math.pi);
                        final breath = 0.96 + (val * 0.04);
                        return GlassContainer(
                          borderRadius: 24,
                          blur: 20,
                          bgOpacity: isDark ? 0.22 : 0.12,
                          borderOpacity: isDark ? 0.16 : 0.22,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 32,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: breath * 1.15,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color(0xFF00FFA3).withValues(
                                          alpha: 0.3 * (0.6 + 0.4 * val),
                                        ),
                                        blurRadius: 36 + (12 * val),
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color:
                                            const Color(0xFF8B5CF6).withValues(
                                          alpha: 0.3 *
                                              (0.6 +
                                                  0.4 *
                                                      math.cos(
                                                        _pulseController.value *
                                                            2 *
                                                            math.pi,
                                                      )),
                                        ),
                                        blurRadius: 40 - (12 * val),
                                        spreadRadius: -2,
                                      ),
                                    ],
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFF00FFA3)
                                            .withValues(alpha: 0.0),
                                        const Color(0xFF8B5CF6)
                                            .withValues(alpha: 0.2),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.psychology,
                                      size: 38,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Синергия думает...',
                                style: textStyle.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Разбираем и выполняем вашу команду',
                                style: textStyle.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
class _VoiceInputButton extends StatelessWidget {
  const _VoiceInputButton({
    required this.voiceState,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });
  final VoiceInputState voiceState;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressEndCallback onLongPressEnd;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      child: Semantics(
        label: l10n.voiceMicTooltip,
        button: true,
        child: SizedBox(
          width: 50,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00FFA3),
                  Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: switch (voiceState) {
                VoiceInputTranscribing() => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                VoiceInputRecording(:final amplitude) =>
                  _PulseDots(amplitude: amplitude),
                _ => const Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}
class _PulseDots extends StatelessWidget {
  const _PulseDots({required this.amplitude});
  final double amplitude;
  @override
  Widget build(BuildContext context) {
    final scale = 0.7 + (amplitude.clamp(0, 1) * 0.6);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final factor = (index - 2).abs() / 2;
        final size = 4 + (scale * 5 * (1 - factor));
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
