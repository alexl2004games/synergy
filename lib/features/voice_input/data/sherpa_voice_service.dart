import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'package:logging/logging.dart';
import '../domain/voice_service.dart';
class SherpaVoiceService implements VoiceService {
  SherpaVoiceService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();
  static const String _assetPrefix =
      'assets/models/sherpa-onnx-nemo-transducer-giga-am-russian-2024-10-24/';
  static const List<String> _requiredAssetFiles = <String>[
    'encoder.int8.onnx',
    'decoder.onnx',
    'joiner.onnx',
    'tokens.txt',
  ];
  static const String _modelDirectoryName =
      'voice_input/sherpa_nemo_transducer_giga_am_russian';
  static const int _sampleRate = 16000;
  static const int _channels = 1;
  final AudioRecorder _recorder;
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();
  final BytesBuilder _audioBuffer = BytesBuilder(copy: false);
  StreamSubscription<Uint8List>? _audioSubscription;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  sherpa_onnx.OfflineRecognizer? _recognizer;
  Directory? _modelDirectory;
  bool _initialized = false;
  bool _isRecording = false;
  final Logger _logger = Logger('SherpaVoiceService');
  @override
  bool get isRecording => _isRecording;
  @override
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _logger.info('Initializing sherpa_onnx recognizer');
    try {
      sherpa_onnx.initBindings();
    } on Object catch (e) {
      _logger.warning('initBindings failed (expected on iOS/macOS): $e');
    }
    _modelDirectory = await _prepareModelDirectory();
    _logger.info('Model directory prepared at: ${_modelDirectory!.path}');
    _recognizer = _buildRecognizer(_modelDirectory!);
    _logger.info('Offline recognizer built');
    _initialized = true;
  }
  @override
  Future<void> startRecording() async {
    if (_isRecording) {
      _logger.fine('startRecording called but already recording');
      return;
    }
    if (!_initialized) {
      _logger.info('Сервис не инициализирован, инициализируем сейчас');
      await initialize();
    }
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    _audioBuffer.clear();
    Stream<Uint8List> audioStream;
    try {
      audioStream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: SherpaVoiceService._sampleRate,
          numChannels: _channels,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
      );
      _isRecording = true;
      _audioSubscription = audioStream.listen(
        _audioBuffer.add,
        onError: (Object error, StackTrace stackTrace) {
          _logger.warning('Audio stream error', error);
        },
      );
      _amplitudeSubscription = _recorder
          .onAmplitudeChanged(
        const Duration(milliseconds: 100),
      )
          .listen((amplitude) {
        final norm = _normalizeAmplitude(amplitude.current);
        _amplitudeController.add(norm);
      });
      _logger.info('Recording started');
    } on Object catch (error, st) {
      _logger.warning('Failed to start stream', error, st);
      _isRecording = false;
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      rethrow;
    }
  }
  @override
  Future<String> stopAndTranscribe() async {
    if (!_isRecording) {
      return '';
    }
    _isRecording = false;
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _recorder.stop();
    final audioBytes = _audioBuffer.takeBytes();
    if (audioBytes.isEmpty) {
      _logger.info('No audio captured');
      return '';
    }
    if (_modelDirectory == null) {
      _logger.warning('Model directory missing, cannot transcribe');
      return '';
    }
    final request = _TranscriptionRequest(
      audioBytes: audioBytes,
      modelDirectory: _modelDirectory!.path,
    );
    _logger.info(
      'Sending audio to isolate for transcription (bytes=${audioBytes.length})',
    );
    return compute(_transcribeInIsolate, request);
  }
  @override
  Future<void> dispose() async {
    _isRecording = false;
    await _amplitudeSubscription?.cancel();
    await _audioSubscription?.cancel();
    await _amplitudeController.close();
    _recognizer?.free();
    _recognizer = null;
    await _recorder.dispose();
  }
  Future<Directory> _prepareModelDirectory() async {
    final tempDirectory = await getTemporaryDirectory();
    final modelDirectory = Directory(
      p.join(tempDirectory.path, _modelDirectoryName),
    );
    await modelDirectory.create(recursive: true);
    for (final fileName in _requiredAssetFiles) {
      final output = File(p.join(modelDirectory.path, fileName));
      if (output.existsSync()) {
        continue;
      }
      final assetPath = '$_assetPrefix$fileName';
      final data = await rootBundle.load(assetPath);
      await output.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    }
    return modelDirectory;
  }
  sherpa_onnx.OfflineRecognizer _buildRecognizer(Directory modelDirectory) {
    final model = sherpa_onnx.OfflineModelConfig(
      transducer: sherpa_onnx.OfflineTransducerModelConfig(
        encoder: p.join(modelDirectory.path, 'encoder.int8.onnx'),
        decoder: p.join(modelDirectory.path, 'decoder.onnx'),
        joiner: p.join(modelDirectory.path, 'joiner.onnx'),
      ),
      tokens: p.join(modelDirectory.path, 'tokens.txt'),
      modelType: 'nemo_transducer',
    );
    final config = sherpa_onnx.OfflineRecognizerConfig(model: model);
    return sherpa_onnx.OfflineRecognizer(config);
  }
}
class _TranscriptionRequest {
  const _TranscriptionRequest({
    required this.audioBytes,
    required this.modelDirectory,
  });
  final Uint8List audioBytes;
  final String modelDirectory;
}
Future<String> _transcribeInIsolate(_TranscriptionRequest request) async {
  try {
    sherpa_onnx.initBindings();
  } on Object {
  }
  final recognizer = sherpa_onnx.OfflineRecognizer(
    sherpa_onnx.OfflineRecognizerConfig(
      model: sherpa_onnx.OfflineModelConfig(
        transducer: sherpa_onnx.OfflineTransducerModelConfig(
          encoder: p.join(request.modelDirectory, 'encoder.int8.onnx'),
          decoder: p.join(request.modelDirectory, 'decoder.onnx'),
          joiner: p.join(request.modelDirectory, 'joiner.onnx'),
        ),
        tokens: p.join(request.modelDirectory, 'tokens.txt'),
        modelType: 'nemo_transducer',
      ),
    ),
  );
  final stream = recognizer.createStream()
    ..acceptWaveform(
      samples: _pcm16ToFloat32(request.audioBytes),
      sampleRate: SherpaVoiceService._sampleRate,
    );
  recognizer.decode(stream);
  final result = recognizer.getResult(stream);
  stream.free();
  recognizer.free();
  return result.text.trim();
}
Float32List _pcm16ToFloat32(Uint8List bytes) {
  final sampleCount = bytes.lengthInBytes ~/ 2;
  final data = ByteData.sublistView(bytes);
  final samples = Float32List(sampleCount);
  for (var index = 0; index < sampleCount; index += 1) {
    samples[index] = data.getInt16(index * 2, Endian.little) / 32768.0;
  }
  return samples;
}
double _normalizeAmplitude(double dbfs) {
  final normalized = (dbfs + 60.0) / 60.0;
  if (normalized.isNaN || !normalized.isFinite) {
    return 0;
  }
  if (normalized < 0) {
    return 0;
  }
  if (normalized > 1) {
    return 1;
  }
  return normalized;
}
