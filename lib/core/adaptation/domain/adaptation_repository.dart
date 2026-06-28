import '../../llm/domain/ai_profile.dart';
abstract class AdaptationRepository {
  Future<AIProfile?> getProfile();
  Stream<AIProfile?> watchProfile();
  Future<void> save(AIProfile profile);
  Future<void> update(AIProfile profile);
}
