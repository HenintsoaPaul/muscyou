import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/hive_service.dart';
import '../models/session.dart';
import '../models/session_template.dart';
import '../models/exercise.dart';

class LocalRepository {
  final HiveService _hiveService;

  LocalRepository(this._hiveService);

  // Sessions
  List<Session> getSessions() {
    return _hiveService.sessionBox.values.toList();
  }

  Session? getSession(String id) {
    // Hive keys are usually dynamic, but if we used put(id, obj), key is id.
    // If we used add(obj), key is int.
    // Let's assume we use put(obj.id, obj).
    return _hiveService.sessionBox.get(id);
  }

  Future<void> saveSession(Session session) async {
    await _hiveService.sessionBox.put(session.id, session);
  }

  Future<void> deleteSession(String id) async {
    await _hiveService.sessionBox.delete(id);
  }

  // Templates
  List<SessionTemplate> getTemplates() {
    return _hiveService.templateBox.values.toList();
  }

  Future<void> saveTemplate(SessionTemplate template) async {
    await _hiveService.templateBox.put(template.id, template);
  }

  Future<void> deleteTemplate(String id) async {
    await _hiveService.templateBox.delete(id);
  }

  // Exercises (Templates/Standalone)
  List<Exercise> getExercises() {
    return _hiveService.exerciseBox.values.toList();
  }

  Future<void> saveExercise(Exercise exercise) async {
    await _hiveService.exerciseBox.put(exercise.id, exercise);
  }
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final localRepositoryProvider = Provider<LocalRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return LocalRepository(hiveService);
});
