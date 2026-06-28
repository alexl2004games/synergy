import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/flutter_gemma_llm_service.dart';
import '../domain/llm_service.dart';
final Provider<LLMService> llmServiceProvider = Provider<LLMService>((ref) {
  final service = FlutterGemmaLLMService();
  ref.onDispose(service.dispose);
  return service;
});
