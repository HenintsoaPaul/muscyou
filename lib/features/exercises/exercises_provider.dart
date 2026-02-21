import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/exercise.dart';
import '../../data/repositories/local_repository.dart';

class ExercisesNotifier extends StateNotifier<List<Exercise>> {
  final LocalRepository _repository;

  ExercisesNotifier(this._repository) : super([]) {
    _loadExercises();
  }

  void _loadExercises() {
    state = _repository.getExercises();
  }

  Future<void> addExercise(Exercise exercise) async {
    await _repository.saveExercise(exercise);
    state = [...state, exercise];
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _repository.saveExercise(exercise);
    state = [
      for (final e in state)
        if (e.id == exercise.id) exercise else e,
    ];
  }

  // Method to refresh if needed (e.g. after sync)
  void refresh() {
    _loadExercises();
  }
}

final exercisesProvider =
    StateNotifierProvider<ExercisesNotifier, List<Exercise>>((ref) {
      final repository = ref.watch(localRepositoryProvider);
      return ExercisesNotifier(repository);
    });
