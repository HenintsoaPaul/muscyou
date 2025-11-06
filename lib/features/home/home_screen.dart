import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String name = "home";

  static String path = "/home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(flex: 2),

                        // Welcome title with slide-in
                        SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            'Hello, Explorer!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 38,
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

                        const SizedBox(height: 16),

                        // Subtitle
                        SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            'Welcome to your expressive journey. Let’s make today vibrant.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // Action card with elevation and glow
                        _buildActionCard(theme),

                        const Spacer(flex: 2),
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
            theme.colorScheme.primary.withOpacity(0.08),
            theme.colorScheme.secondary.withOpacity(0.05),
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

  Widget _buildActionCard(ThemeData theme) {
    return SlideTransition(
      position: _slideAnimation,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surfaceVariant.withOpacity(0.7),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: const Icon(Icons.explore, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Exploring',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to begin your adventure',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  ConfettiPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = List.generate(12, (i) => i);

    for (int i = 0; i < 12; i++) {
      final t = (progress + i * 0.08) % 1.0;
      final x = (i % 4) * (size.width / 4) + (t * 100) % 80 - 40;
      final y = -50 - (t * size.height * 1.3);
      final rotation = t * 6.28;
      final scale = (1 - t) * 0.8 + 0.2;

      final color = colors[i % colors.length].withOpacity(1 - t);

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
