import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimerState {
  final Duration duration;
  final bool isRunning;
  final String? sessionId;

  TimerState({required this.duration, required this.isRunning, this.sessionId});

  factory TimerState.initial() {
    return TimerState(duration: Duration.zero, isRunning: false);
  }

  TimerState copyWith({
    Duration? duration,
    bool? isRunning,
    String? sessionId,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      isRunning: isRunning ?? this.isRunning,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;

  TimerNotifier() : super(TimerState.initial());

  void startTimer(String sessionId, {Duration? initialDuration}) {
    if (state.isRunning) return;

    state = state.copyWith(
      isRunning: true,
      sessionId: sessionId,
      duration: initialDuration ?? Duration.zero,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        duration: state.duration + const Duration(seconds: 1),
      );
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    stopTimer();
    state = TimerState.initial();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
