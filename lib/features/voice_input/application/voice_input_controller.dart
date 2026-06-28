import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:logging/logging.dart';
import '../domain/voice_service.dart';
sealed class VoiceInputState {
  const VoiceInputState();
}
final class VoiceInputIdle extends VoiceInputState {
  const VoiceInputIdle();
}
final class VoiceInputRecording extends VoiceInputState {
  const VoiceInputRecording(this.amplitude);
  final double amplitude;
}
final class VoiceInputTranscribing extends VoiceInputState {
  const VoiceInputTranscribing();
}
final class VoiceInputDone extends VoiceInputState {
  const VoiceInputDone(this.text);
  final String text;
}
final class VoiceInputError extends VoiceInputState {
  const VoiceInputError(this.message);
  final String message;
}
class VoiceInputController extends StateNotifier<VoiceInputState> {
  VoiceInputController(this._voiceService) : super(const VoiceInputIdle());
  final VoiceService _voiceService;
  final Logger _logger = Logger('VoiceInputController');
  StreamSubscription<double>? _amplitudeSubscription;
  Future<void> startRecording() async {
    if (_voiceService.isRecording) {
      return;
    }
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    try {
      _logger
        ..info('Requesting microphone permission')
        ..info('Starting voice recording');
      await _voiceService.initialize();
      await _voiceService.startRecording();
    } on Object catch (error, st) {
      final errorMsg = error.toString();
      _logger.warning(
        'Failed to start recording | error: $errorMsg',
        error,
        st,
      );
      state = VoiceInputError(errorMsg);
      return;
    }
    state = const VoiceInputRecording(0);
    _amplitudeSubscription = _voiceService.amplitudeStream.listen(
      _handleAmplitude,
    );
  }
  void _handleAmplitude(double amplitude) {
    if (!_voiceService.isRecording) {
      return;
    }
    state = VoiceInputRecording(amplitude);
  }
  Future<String> stopAndTranscribe() async {
    if (!_voiceService.isRecording) {
      return switch (state) {
        VoiceInputDone(:final text) => text,
        _ => '',
      };
    }
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    state = const VoiceInputTranscribing();
    try {
      _logger.info('Stopping recording and transcribing');
      final text = await _voiceService.stopAndTranscribe();
      _logger.info('Transcription finished (len=${text.length})');
      state = VoiceInputDone(text);
      return text;
    } on Object catch (error, st) {
      _logger.warning('Transcription failed', error, st);
      final message = error.toString();
      state = VoiceInputError(message);
      return '';
    }
  }
  @override
  void dispose() {
    unawaited(_amplitudeSubscription?.cancel());
    super.dispose();
  }
}
