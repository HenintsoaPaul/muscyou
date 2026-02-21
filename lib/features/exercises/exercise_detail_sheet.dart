import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/exercise.dart';
import '../home/performance_provider.dart';
import 'exercise_form.dart';
import 'exercises_provider.dart';

class ExerciseDetailSheet extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseDetailSheet({super.key, required this.exercise});

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ExerciseForm(
          initialExercise: exercise,
          onSave: (name, description, repetitionsExpected, durationExpected) {
            final updated = exercise.copyWith(
              name: name,
              description: description,
              repetitionsExpected: repetitionsExpected,
              durationExpected: durationExpected,
            );
            ref.read(exercisesProvider.notifier).updateExercise(updated);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final performanceData = ref.watch(performanceProvider);
    final history = performanceData.exerciseProgress[exercise.name] ?? [];

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
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: Text(
                        exercise.name,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showEditSheet(context, ref),
                    ),
                  ),
                ],
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

              if (history.isNotEmpty) ...[
                Text(
                  'Progress (${history.first.label})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressChart(theme, history),
                const SizedBox(height: 24),
              ],

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

  Widget _buildProgressChart(ThemeData theme, List<ExerciseProgress> history) {
    return Container(
      height: 150,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: history.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.value);
              }).toList(),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= history.length) {
                    return const SizedBox();
                  }
                  return Text(
                    DateFormat('Md').format(history[index].date),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
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
