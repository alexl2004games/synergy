import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/sherpa_voice_service.dart';
import '../domain/voice_service.dart';
import 'voice_input_controller.dart';
final Provider<VoiceService> voiceServiceProvider =
    Provider<VoiceService>((ref) => SherpaVoiceService());
// ignore: specify_nonobvious_property_types
final voiceInputControllerProvider =
    StateNotifierProvider.autoDispose<VoiceInputController, VoiceInputState>(
  (ref) => VoiceInputController(ref.read(voiceServiceProvider)),
);
