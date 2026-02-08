import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';

class ExerciseDetailSheet extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailSheet({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                exercise.name,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              if (exercise.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  exercise.description!,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              
              _DetailRow(
                label: 'Expected Duration',
                value: exercise.durationExpected != null 
                    ? '${exercise.durationExpected}s' 
                    : 'Not set',
                icon: Icons.timer_outlined,
              ),
              _DetailRow(
                label: 'Expected Reps',
                value: exercise.repetitionsExpected != null 
                    ? '${exercise.repetitionsExpected}' 
                    : 'Not set',
                icon: Icons.repeat,
              ),
              
              const SizedBox(height: 32),
              
              FilledButton.icon(
                onPressed: () {
                  // Add to session logic would go here
                  Navigator.pop(context, 'add');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add to Session'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
