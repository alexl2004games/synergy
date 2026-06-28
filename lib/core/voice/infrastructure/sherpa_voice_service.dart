import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import '../application/voice_service.dart';
class SherpaVoiceService implements VoiceService {
  final _log = Logger('SherpaVoiceService');
  final AudioRecorder _recorder = AudioRecorder();
  OfflineRecognizer? _recognizer;
  StreamSubscription<Uint8List>? _audioSubscription;
  final List<double> _audioBuffer = [];
  final _stateController = StreamController<VoiceRecordingState>.broadcast();
  VoiceRecordingState _currentState = VoiceRecordingState.idle;
  Timer? _silenceTimer;
  final double _silenceThreshold = 0.05;
  void _updateState(VoiceRecordingState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }
  @override
  Stream<VoiceRecordingState> get stateStream => _stateController.stream;
  @override
  Future<void> init() async {
    _log.info('Initializing SherpaVoiceService');
    try {
      const config = OfflineRecognizerConfig(
        model: OfflineModelConfig(
          transducer: OfflineTransducerModelConfig(
            encoder:
                'assets/models/sherpa-onnx-nemo-transducer-giga-am-russian-2024-10-24/encoder.int8.onnx',
            decoder:
                'assets/models/sherpa-onnx-nemo-transducer-giga-am-russian-2024-10-24/decoder.onnx',
            joiner:
                'assets/models/sherpa-onnx-nemo-transducer-giga-am-russian-2024-10-24/joiner.onnx',
          ),
          tokens:
              'assets/models/sherpa-onnx-nemo-transducer-giga-am-russian-2024-10-24/tokens.txt',
          modelType: 'transducer',
        ),
      );
      _recognizer = OfflineRecognizer(config);
      _log.info('SherpaVoiceService initialized successfully');
    } on Object catch (e, stack) {
      _log.severe('Failed to initialize SherpaVoiceService', e, stack);
    }
  }
  @override
  Future<void> startRecording() async {
    if (_currentState != VoiceRecordingState.idle) {
      _log.warning('Cannot start recording from state $_currentState');
      return;
    }
    final isGranted = await Permission.microphone.request().isGranted;
    if (!isGranted) {
      _log.warning('Microphone permission denied');
      _updateState(VoiceRecordingState.error);
      return;
    }
    try {
      _audioBuffer.clear();
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      _updateState(VoiceRecordingState.recording);
      _audioSubscription = stream.listen(_handleAudioData);
      _resetSilenceTimer();
    } on Object catch (e, stack) {
      _log.severe('Error starting recording', e, stack);
      _updateState(VoiceRecordingState.error);
    }
  }
  void _handleAudioData(Uint8List data) {
    final byteData = ByteData.sublistView(data);
    final count = data.length ~/ 2;
    final floats = Float32List(count);
    var maxAmplitude = 0.0;
    for (var i = 0; i < count; i++) {
      final pcm16 = byteData.getInt16(i * 2, Endian.little);
      final value = pcm16 / 32768.0;
      floats[i] = value;
      maxAmplitude = math.max(maxAmplitude, value.abs());
    }
    _audioBuffer.addAll(floats);
    if (maxAmplitude > _silenceThreshold) {
      _resetSilenceTimer();
    }
  }
  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_currentState == VoiceRecordingState.recording) {
        _log.info('Silence detected, automatically stopping recording');
        unawaited(stopRecording());
      }
    });
  }
  @override
  Future<String> stopRecording() async {
    if (_currentState != VoiceRecordingState.recording) {
      return '';
    }
    _updateState(VoiceRecordingState.transcribing);
    _silenceTimer?.cancel();
    await _audioSubscription?.cancel();
    await _recorder.stop();
    if (_recognizer == null || _audioBuffer.isEmpty) {
      _updateState(VoiceRecordingState.idle);
      return '';
    }
    try {
      final stream = _recognizer!.createStream()
        ..acceptWaveform(
          sampleRate: 16000,
          samples: Float32List.fromList(_audioBuffer),
        );
      _recognizer!.decode(stream);
      final result = _recognizer!.getResult(stream);
      stream.free();
      _updateState(VoiceRecordingState.idle);
      return result.text.trim();
    } on Object catch (e, stack) {
      _log.severe('Error decoding audio', e, stack);
      _updateState(VoiceRecordingState.error);
      return '';
    }
  }
  @override
  Future<void> cancelRecording() async {
    _silenceTimer?.cancel();
    await _audioSubscription?.cancel();
    await _recorder.stop();
    _audioBuffer.clear();
    _updateState(VoiceRecordingState.idle);
  }
  @override
  Future<void> dispose() async {
    _silenceTimer?.cancel();
    await _audioSubscription?.cancel();
    await _recorder.dispose();
    _recognizer?.free();
    await _stateController.close();
  }
}
