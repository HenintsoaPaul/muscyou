import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../dashboard/dashboard_provider.dart';
import '../history/session_history_screen.dart';
import '../history/session_detail_sheet.dart';
import 'performance_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static String name = "home";
  static String path = "/home";

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _confettiController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.easeOutQuart),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _slideController.forward();
      _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final dashboardState = ref.watch(dashboardProvider);
    final performanceData = ref.watch(performanceProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _confettiController]),
        builder: (context, child) {
          return Stack(
            children: [
              // Subtle animated gradient background
              _buildAnimatedBackground(size, theme),

              // Confetti overlay (subtle floating particles)
              _buildConfettiLayer(size, theme),

              // Main content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Welcome title with slide-in
                        SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            'MuscYou Overview',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader =
                                    LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 300, 50),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                title: 'Workouts',
                                value: dashboardState.totalWorkouts.toString(),
                                icon: Icons.fitness_center,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _SummaryCard(
                                title: 'Time',
                                value: _formatDuration(
                                  dashboardState.totalDuration,
                                ),
                                icon: Icons.timer,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Performance Section
                        Text(
                          'Weekly Activity',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildWeeklyChart(
                          theme,
                          performanceData.weeklyActivity,
                        ),

                        const SizedBox(height: 32),

                        // Recent Sessions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Sessions',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push(SessionHistoryScreen.path),
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (dashboardState.recentSessions.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                'No recent workouts. Time to start!',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dashboardState.recentSessions.length,
                            itemBuilder: (context, index) {
                              final session =
                                  dashboardState.recentSessions[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                color: theme.colorScheme.surfaceContainerLow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: Text(
                                      session.name.isNotEmpty
                                          ? session.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    session.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    session.startTimestamp != null
                                        ? DateFormat.yMMMd().add_jm().format(
                                            session.startTimestamp!,
                                          )
                                        : 'Not started',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          SessionDetailSheet(session: session),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeeklyChart(
    ThemeData theme,
    List<DailyActivity> weeklyActivity,
  ) {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weeklyActivity.length) {
                    return const SizedBox();
                  }
                  final date = weeklyActivity[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('E').format(date)[0],
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
          barGroups: weeklyActivity.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.sessionCount.toDouble(),
                  color: theme.colorScheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(seconds: 4),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.8,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
            theme.colorScheme.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiLayer(Size size, ThemeData theme) {
    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: ConfettiPainter(
          progress: _confettiAnimation.value,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
            theme.colorScheme.tertiary,
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  ConfettiPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final t = (progress + i * 0.08) % 1.0;
      final x = (i % 4) * (size.width / 4) + (t * 100) % 80 - 40;
      final y = -50 - (t * size.height * 1.3);
      final rotation = t * 6.28;
      final scale = (1 - t) * 0.8 + 0.2;

      final color = colors[i % colors.length].withValues(alpha: 1 - t);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.scale(scale);

      paint.color = color;
      final path = Path()
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: 6));

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
