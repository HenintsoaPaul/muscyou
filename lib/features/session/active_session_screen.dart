import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'session_provider.dart';
import 'timer_provider.dart';
import '../../data/models/session.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key});

  static const String name = 'active_session';
  static const String path = '/session/active';

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start new session if none active
    // This logic might need refinement for creating from templates vs scratch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(sessionProvider);
      if (session == null) {
        final newSession = Session.create(name: "New Workout"); // Default name
        ref.read(sessionProvider.notifier).startSession(newSession);
      }
    });
  }

  void _finishSession() {
    // Show confirmation dialog?
    ref.read(sessionProvider.notifier).endSession();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final timerState = ref.watch(timerProvider);
    final theme = Theme.of(context);

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } // Should handle this better

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name),
        actions: [
          // Timer display in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: timerState.isRunning ? 1.1 : 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: timerState.isRunning
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        _formatDuration(timerState.duration),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Simple continuous pulse not easily done with TweenAnimationBuilder alone without state trigger
                  // For MVP, this adds a subtle pop when state changes or builds.
                  // Real pulse needs AnimationController.
                  // Let's stick to a simple shadow glow for now which is safer.
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: session.exercises.isEmpty
                ? Center(
                    child: Text(
                      'No exercises added yet.\nTap + to add.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: session.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = session.exercises[index];
                      return ListTile(
                        title: Text(exercise.name),
                        subtitle: Text(
                          exercise.description ?? 'No description',
                        ),
                        trailing: Checkbox(
                          value: exercise.isCompleted,
                          onChanged: (val) {
                            // Update exercise completion status
                            final updated = exercise.copyWith(isCompleted: val);
                            ref
                                .read(sessionProvider.notifier)
                                .updateExercise(index, updated);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_exercise_to_session_fab',
            onPressed: () {
              // Open exercise picker (could reuse ExerciseListScreen logic or distinct picker)
              // For MVP, simplistic mock add
              context.push(
                '/exercises',
              ); // Ideally selecting one adds it to session
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'start_session_fab', // Matches Dashboard to morph
            onPressed: _finishSession,
            label: const Text('Finish'),
            icon: const Icon(Icons.check),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    return '$hours$minutes:$seconds';
  }
}
