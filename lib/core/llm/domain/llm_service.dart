import 'ai_profile.dart';
import 'task_draft.dart';
abstract class LLMService {
  Future<TaskDraft> parseTask(String text, AIProfile profile);
  Future<void> dispose();
}
