import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:muscyou/features/login/auth_exception.dart';
import 'package:muscyou/features/login/auth_state.dart';
import 'package:muscyou/l10n/app_localizations.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  static String name = "login";
  static String path = "/login";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());
    // Controllers
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    // FocusNodes
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    // Animation controllers with vsync handled internally by useAnimationController hook
    final fadeController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    final slideController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );
    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 3000),
    );
    final rippleController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    // Animations from controllers
    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: fadeController, curve: Curves.easeOutCubic),
      ),
    );
    final slideAnimation = useAnimation(
      Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: slideController, curve: Curves.elasticOut),
      ),
    );
    final pulseAnimation = useAnimation(
      Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
      ),
    );
    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: rippleController, curve: Curves.easeOutCubic),
      ),
    );

    // State hooks
    final isPasswordVisible = useState(false);
    final isSubmitting = useState(false);

    // Start animations once on widget load
    useEffect(() {
      fadeController.forward();
      slideController.forward();
      pulseController.repeat(reverse: true);
      return () {
        // fadeController.dispose();
        // slideController.dispose();
        // pulseController.dispose();
        // rippleController.dispose();
      };
    }, []);

    void triggerRipple() {
      rippleController.forward(from: 0.0);
    }

    Future<void> handleLogin() async {
      try {
        if (formKey.currentState!.validate()) {
          isSubmitting.value = true;
          triggerRipple();

          String email = emailController.text;
          String password = passwordController.text;

          // Make user wait so that loading icon shows properly
          await Future.delayed(const Duration(seconds: 1));
          try {
            await ref.read(authProvider.notifier).authenticate(email, password);
          } on AuthException catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.message(l10n)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      } finally {
        if (context.mounted) isSubmitting.value = false;
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          fadeController,
          pulseController,
          rippleController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Animated gradient background with pulse
              _buildAnimatedBackground(size, theme, pulseAnimation),

              // Ripple effect overlay
              if (rippleController.value > 0)
                _buildRippleEffect(size, scaleAnimation),

              // Main content
              SafeArea(
                child: FadeTransition(
                  opacity: fadeController,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: size.height - 100),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 2),
                            _buildAnimatedLogo(theme),
                            const SizedBox(height: 32),
                            _buildAnimatedTitle(theme, fadeController),
                            const SizedBox(height: 48),
                            // SlideTransition(
                            //   position: slideAnimation,
                            //   child: _buildLoginForm(
                            //     theme,
                            //     formKey,
                            //     emailController,
                            //     passwordController,
                            //     emailFocus,
                            //     passwordFocus,
                            //     isPasswordVisible,
                            //     isSubmitting,
                            //     () => isPasswordVisible.value = !isPasswordVisible.value,
                            //     handleLogin,
                            //   ),
                            // ),
                            _buildLoginForm(
                              theme,
                              formKey,
                              emailController,
                              passwordController,
                              emailFocus,
                              passwordFocus,
                              isPasswordVisible,
                              isSubmitting,
                              () => isPasswordVisible.value =
                                  !isPasswordVisible.value,
                              handleLogin,
                            ),
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
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

  Widget _buildAnimatedBackground(
    Size size,
    ThemeData theme,
    double pulseValue,
  ) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: pulseValue * 1.5,
          colors: [
            theme.colorScheme.primary.withOpacity(0.12),
            theme.colorScheme.secondary.withOpacity(0.08),
            theme.colorScheme.tertiary.withOpacity(0.05),
            theme.colorScheme.surface,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildRippleEffect(Size size, double scaleValue) {
    return Positioned(
      top: size.height * 0.6,
      left: size.width / 2,
      child: Transform.translate(
        offset: const Offset(-150, -150),
        child: SizedBox(
          width: 300,
          height: 300,
          child: CustomPaint(painter: RipplePainter(scaleValue)),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(ThemeData theme) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                    theme.colorScheme.tertiary,
                    theme.colorScheme.primary,
                  ],
                  stops: const [0.0, 0.33, 0.66, 1.0],
                  transform: GradientRotation(value * 3.14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: value * 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedTitle(
    ThemeData theme,
    AnimationController fadeController,
  ) {
    const title = 'Welcome Back';
    const subtitle = 'Sign in to continue your journey';

    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ).createShader(bounds),
          child: Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: fadeController,
          builder: (context, child) {
            return Opacity(
              opacity: fadeController.value,
              child: Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoginForm(
    ThemeData theme,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
    FocusNode emailFocus,
    FocusNode passwordFocus,
    ValueNotifier<bool> isPasswordVisible,
    ValueNotifier<bool> isSubmitting,
    VoidCallback togglePasswordVisibility,
    Future<void> Function() handleLogin,
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _buildAnimatedTextField(
                controller: emailController,
                focusNode: emailFocus,
                label: 'Email',
                hint: 'you@example.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildAnimatedTextField(
                controller: passwordController,
                focusNode: passwordFocus,
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscureText: !isPasswordVisible.value,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      key: ValueKey(isPasswordVisible.value),
                    ),
                  ),
                  onPressed: togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLoginButton(theme, isSubmitting.value, handleLogin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                prefixIcon: Icon(icon),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              validator: validator,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton(
    ThemeData theme,
    bool isSubmitting,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSubmitting ? 28 : 16),
          gradient: LinearGradient(
            colors: isSubmitting
                ? [theme.colorScheme.primary, theme.colorScheme.primary]
                : [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(isSubmitting ? 28 : 16),
            onTap: isSubmitting ? null : onPressed,
            child: Center(
              child: isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double progress;

  RipplePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = progress * size.width;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
