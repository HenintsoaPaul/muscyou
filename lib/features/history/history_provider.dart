import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/session.dart';
import '../../data/repositories/local_repository.dart';

final historyProvider = Provider<List<Session>>((ref) {
  final repository = ref.watch(localRepositoryProvider);
  final sessions = repository.getSessions();

  // Sort by date descending
  sessions.sort((a, b) {
    if (a.startTimestamp == null && b.startTimestamp == null) return 0;
    if (a.startTimestamp == null) return 1;
    if (b.startTimestamp == null) return -1;
    return b.startTimestamp!.compareTo(a.startTimestamp!);
  });

  return sessions;
});
