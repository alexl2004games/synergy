import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter/services.dart';
import 'package:smart_diary/features/ai_engine/data/flutter_gemma_llm_service.dart';
import 'package:smart_diary/core/llm/domain/ai_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const runIntegration = bool.fromEnvironment('RUN_GEMMA_INTEGRATION');

  test(
    'Gemma4 parseTask integration (requires model and env)',
    () async {
      if (!runIntegration) {
        return;
      }

      // Basic integration: initialize FlutterGemma and call parseTask once.
      try {
        await FlutterGemma.initialize();
      } on MissingPluginException {
        // plugin channels are unavailable in this test runner
        return;
      }

      final service = FlutterGemmaLLMService();
      try {
        await service.initialize();
      } on MissingPluginException {
        return;
      }

      const profile = AIProfile();
      DateTime? parsedStartAt;
      try {
        final result = await service.parseTask(
          'Сходить сегодня в магазин в 13:00',
          profile,
        );
        parsedStartAt = result.task.startAt;
      } on MissingPluginException {
        return;
      }

      expect(parsedStartAt, isNotNull);
      await service.dispose();
    },
    timeout: const Timeout.factor(6),
  );
}
