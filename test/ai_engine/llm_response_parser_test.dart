import 'package:flutter_test/flutter_test.dart';
import 'package:smart_diary/features/ai_engine/application/llm_response_parser.dart';
import 'package:smart_diary/core/llm/domain/ai_profile.dart';
import 'package:smart_diary/features/ai_engine/domain/llm_service.dart'
    as domain;

void main() {
  group('LLMResponseParser', () {
    const parser = LLMResponseParser();

    test('parseFromMap parses start_at and title correctly', () async {
      final json = {
        'title': 'Сходить в магазин',
        'notes': 'Купить молоко',
        'start_at': '2026-05-10T13:00:00',
        'end_at': null,
        'deadline_at': null,
        'is_all_day': false,
        'est_min': 30,
        'priority': 'medium',
        'tags': ['shopping'],
        'confidence': 0.9,
      };

      final result = await parser.parseFromMap(
        userText: 'Сходить сегодня в магазин в 13:00',
        json: json,
        profile: const AIProfile(),
        rawResponse: json.toString(),
      );

      expect(result.task.title, equals('Сходить в магазин'));
      expect(result.task.startAt, isNotNull);
      expect(result.task.startAt!.year, equals(2026));
      expect(result.task.startAt!.hour, equals(13));
      expect(result.quality, equals(domain.ParseQuality.high));
    });

    test('parse repairs truncated JSON correctly', () async {
      const rawResponse =
          '{"action":"create_tasks","tasks":[{"title":"купить хлеб","notes":null,"start_at":"2026-05-27T00:00:00","end_at":null,"deadline_at":null,"is_all_day":true,"est_min":60,"priority":"medium","tags":["groceries"],"checklist_items":["хлеб","молоко"],"recurrence_rule":null,"confidence":1.0},{"title":"спортзал","notes":null,"start_at":"2026-05-26T18:00:00","end_at":"2026-05-26T20:00:00","deadline_at":null,"is_all_day":false,"est_min":120,"priority":"medium"';

      final result = await parser.parse(
        userText:
            'купить хлеб и молоко завтра, а в пятницу в 18:00 спортзал на 2 часа',
        rawResponse: rawResponse,
        profile: const AIProfile(),
      );

      expect(result.tasks.length, equals(2));
      expect(result.tasks[0].title, equals('купить хлеб'));
      expect(result.tasks[1].title, equals('спортзал'));
      expect(result.tasks[1].estMin, equals(120));
      expect(result.quality, equals(domain.ParseQuality.high));
    });
  });
}
