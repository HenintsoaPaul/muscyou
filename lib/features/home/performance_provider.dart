import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:muscyou/data/models/session.dart';
import '../../data/repositories/local_repository.dart';

class PerformanceData {
  final List<DailyActivity> weeklyActivity;
  final Map<String, List<ExerciseProgress>> exerciseProgress;

  PerformanceData({
    required this.weeklyActivity,
    required this.exerciseProgress,
  });
}

class DailyActivity {
  final DateTime date;
  final int sessionCount;

  DailyActivity(this.date, this.sessionCount);
}

class ExerciseProgress {
  final DateTime date;
  final double value; // Can be reps or weight/duration if we add more
  final String label;

  ExerciseProgress({
    required this.date,
    required this.value,
    required this.label,
  });
}

final performanceProvider = Provider<PerformanceData>((ref) {
  final repository = ref.watch(localRepositoryProvider);
  final sessions = repository.getSessions();

  // 1. Calculate Weekly Activity (Last 7 days)
  final now = DateTime.now();
  final weeklyActivity = List.generate(7, (index) {
    final date = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: 6 - index));
    final count = sessions.where((s) {
      if (s.startTimestamp == null) return false;
      return s.startTimestamp!.year == date.year &&
          s.startTimestamp!.month == date.month &&
          s.startTimestamp!.day == date.day;
    }).length;
    return DailyActivity(date, count);
  });

  // 2. Calculate Exercise Progress
  final Map<String, List<ExerciseProgress>> exerciseProgress = {};

  // Sort sessions by date
  final sortedSessions = List<Session>.from(sessions)
    ..sort(
      (a, b) => (a.startTimestamp ?? DateTime(0)).compareTo(
        b.startTimestamp ?? DateTime(0),
      ),
    );

  for (final session in sortedSessions) {
    if (session.startTimestamp == null) continue;

    for (final exercise in session.exercises) {
      if (!exercise.isCompleted) continue;

      final progressList = exerciseProgress.putIfAbsent(
        exercise.name,
        () => [],
      );

      // We prioritize repetitions for progress, fall back to duration
      double value = 0.0;
      String label = '';

      if (exercise.repetitionsActual != null &&
          exercise.repetitionsActual! > 0) {
        value = exercise.repetitionsActual!.toDouble();
        label = 'Reps';
      } else if (exercise.durationActual != null &&
          exercise.durationActual! > 0) {
        value = exercise.durationActual!.toDouble();
        label = 'Seconds';
      }

      if (value > 0) {
        progressList.add(
          ExerciseProgress(
            date: session.startTimestamp!,
            value: value,
            label: label,
          ),
        );
      }
    }
  }

  return PerformanceData(
    weeklyActivity: weeklyActivity,
    exerciseProgress: exerciseProgress,
  );
});
