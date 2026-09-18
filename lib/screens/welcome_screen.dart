import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';
import '../theme/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const karmaRed = AppColors.karmaRed;
    const karmaRedDark = Color(0xFF8E1B1B);

    final background = AppColors.background.resolveFrom(context);
    final textPrimary = AppColors.textPrimary.resolveFrom(context);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: background,
      child: DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: Column(
          children: [
            // ============================================================
            // TOP HEADER — gradient + curved bottom edge
            // ============================================================
            Expanded(
              flex: 5,
              child: ClipPath(
                clipper: _BottomWaveClipper(),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [karmaRed, karmaRedDark],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Glow behind logo
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.white.withValues(
                                  alpha: 0.08,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoColors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 40,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CupertinoColors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.asset(
                                      'assets/images/logo.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'KarmaHR',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: CupertinoColors.white.withValues(
                                    alpha: 0.25,
                                  ),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                'Human Resource Management',
                                style: TextStyle(
                                  color: CupertinoColors.white.withValues(
                                    alpha: 0.95,
                                  ),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ============================================================
            // BOTTOM SECTION — welcome, tagline, CTA
            // ============================================================
            Expanded(
              flex: 4,
              child: SafeArea(
                top: false,
                child: SlideTransition(
                  position: _slideUp,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Description
                          const Text(
                            'Manage attendance, leave, requests, and more with KarmaHR.',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: CupertinoColors.systemGrey,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // GET STARTED BUTTON
                          GestureDetector(
                            onTapDown: (_) => setState(() => _isPressed = true),
                            onTapUp: (_) {
                              setState(() => _isPressed = false);
                              HapticFeedback.lightImpact();
                              Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            onTapCancel: () =>
                                setState(() => _isPressed = false),
                            child: AnimatedScale(
                              scale: _isPressed ? 0.97 : 1.0,
                              duration: const Duration(milliseconds: 120),
                              child: Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [karmaRed, karmaRedDark],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: karmaRed.withValues(
                                        alpha: isDark ? 0.25 : 0.35,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: CupertinoColors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      CupertinoIcons.arrow_right,
                                      color: CupertinoColors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.lock_shield_fill,
                                  size: 12,
                                  color: CupertinoColors.systemGrey2
                                      .resolveFrom(context),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Protected & confidential · Authorized staff only',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: CupertinoColors.systemGrey2
                                        .resolveFrom(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// Curved bottom edge for the red header
// =============================================================
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 40,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
