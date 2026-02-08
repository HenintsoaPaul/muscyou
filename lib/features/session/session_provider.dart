import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/session.dart';
import '../../data/models/exercise.dart';
import '../../data/repositories/local_repository.dart';
import 'timer_provider.dart';

class SessionNotifier extends StateNotifier<Session?> {
  final LocalRepository _repository;
  final TimerNotifier _timerNotifier;

  SessionNotifier(this._repository, this._timerNotifier) : super(null);

  Future<void> startSession(Session session) async {
    // If there's already an active session, we might want to prevent starting a new one or end the old one.
    // For MVP, simplistic approach: replace it.

    final activeSession = session.copyWith(startTimestamp: DateTime.now());
    state = activeSession;
    await _repository.saveSession(activeSession);

    _timerNotifier.startTimer(activeSession.id);
  }

  Future<void> endSession() async {
    if (state == null) return;

    final completedSession = state!.copyWith(
      endTimestamp: DateTime.now(),
      isCompleted: true,
    );

    state = null; // Clear active session from state logic (or move to summary)
    await _repository.saveSession(completedSession);

    _timerNotifier.resetTimer();
  }

  Future<void> addExercise(Exercise exercise) async {
    if (state == null) return;

    final updatedExercises = [...state!.exercises, exercise];
    final updatedSession = state!.copyWith(exercises: updatedExercises);
    state = updatedSession;
    await _repository.saveSession(updatedSession);
  }

  Future<void> updateExercise(int index, Exercise exercise) async {
    if (state == null) return;

    if (index < 0 || index >= state!.exercises.length) return;

    final updatedExercises = [...state!.exercises];
    updatedExercises[index] = exercise;

    final updatedSession = state!.copyWith(exercises: updatedExercises);
    state = updatedSession;
    await _repository.saveSession(updatedSession);
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, Session?>((ref) {
  final repository = ref.watch(localRepositoryProvider);
  final timerNotifier = ref.watch(timerProvider.notifier);
  return SessionNotifier(repository, timerNotifier);
});
