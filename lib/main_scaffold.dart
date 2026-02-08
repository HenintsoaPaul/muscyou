import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:go_router/go_router.dart';
import '../features/session/timer_provider.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,

          // Global Timer Overlay
          if (timerState.isRunning)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  context.push('/session/active');
                },
                child: Hero(
                  tag: 'global_timer',
                  child: Material(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Role(timerState: timerState),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class Role extends StatelessWidget {
  final TimerState timerState;
  const Role({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    final hours = timerState.duration.inHours;
    final minutes = timerState.duration.inMinutes.remainder(60);
    final seconds = timerState.duration.inSeconds.remainder(60);
    final timeString =
        '${hours > 0 ? '$hours:' : ''}'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer, size: 16),
        const SizedBox(width: 4),
        Text(timeString, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
