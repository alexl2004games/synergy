import 'dart:async';
abstract class VoiceService {
  bool get isRecording;
  Stream<double> get amplitudeStream;
  Future<void> initialize();
  Future<void> startRecording();
  Future<String> stopAndTranscribe();
  Future<void> dispose();
}
