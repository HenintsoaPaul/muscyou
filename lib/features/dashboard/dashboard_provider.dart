import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/models/session.dart';
import '../../data/repositories/local_repository.dart';

class DashboardState {
  final List<Session> recentSessions;
  final int totalWorkouts;
  final Duration totalDuration;

  DashboardState({
    required this.recentSessions,
    required this.totalWorkouts,
    required this.totalDuration,
  });
}

final dashboardProvider = Provider<DashboardState>((ref) {
  final repository = ref.watch(localRepositoryProvider);
  final sessions = repository.getSessions();

  // Sort by date descending
  sessions.sort((a, b) {
    if (a.startTimestamp == null && b.startTimestamp == null) return 0;
    if (a.startTimestamp == null) return 1;
    if (b.startTimestamp == null) return -1;
    return b.startTimestamp!.compareTo(a.startTimestamp!);
  });

  final completedSessions = sessions.where((s) => s.isCompleted).toList();

  final totalDuration = completedSessions.fold(Duration.zero, (prev, element) {
    if (element.startTimestamp != null && element.endTimestamp != null) {
      return prev + element.endTimestamp!.difference(element.startTimestamp!);
    }
    return prev;
  });

  return DashboardState(
    recentSessions: sessions.take(5).toList(),
    totalWorkouts: completedSessions.length,
    totalDuration: totalDuration,
  );
});
