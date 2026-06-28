import 'dart:async';
enum VoiceRecordingState {
  idle,
  recording,
  transcribing,
  error,
}
abstract class VoiceService {
  Future<void> init();
  Future<void> startRecording();
  Future<String> stopRecording();
  Future<void> cancelRecording();
  Stream<VoiceRecordingState> get stateStream;
  Future<void> dispose();
}
