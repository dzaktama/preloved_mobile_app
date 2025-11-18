import 'package:flutter/material.dart';
import 'dart:async';
import 'package:preloved_mobile_app/view/registerScreen.dart';

// SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  double _progress = 0.0;
  Timer? _progressTimer;

  // Custom colors
  static const Color roseLight = Color(0xFFFFF1F2);
  static const Color roseMedium = Color(0xFFFDA4AF);
  static const Color roseDark = Color(0xFFF43F5E);
  static const Color purpleLight = Color(0xFFFAF5FF);
  static const Color purpleMedium = Color(0xFFC084FC);
  static const Color purpleDark = Color(0xFF9333EA);
  static const Color indigoLight = Color(0xFFEEF2FF);
  static const Color indigoMedium = Color(0xFF818CF8);
  static const Color indigoDark = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Progress bar animation
    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_progress >= 1.0) {
          timer.cancel();
          _progress = 1.0;
        } else {
          _progress += 0.02;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _navigateToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _navigateToRegister,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                roseLight,
                purpleLight,
                indigoLight,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background circles
              Positioned(
                top: 80,
                left: 40,
                child: _AnimatedCircle(
                  size: 280,
                  color: roseMedium,
                  delay: 0,
                ),
              ),
              Positioned(
                top: 160,
                right: 40,
                child: _AnimatedCircle(
                  size: 280,
                  color: purpleMedium,
                  delay: 1,
                ),
              ),
              Positioned(
                bottom: -80,
                left: MediaQuery.of(context).size.width / 2 - 140,
                child: _AnimatedCircle(
                  size: 280,
                  color: indigoMedium,
                  delay: 2,
                ),
              ),

              // Main content
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container with floating icons
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Floating hearts and sparkles
                            const Positioned(
                              top: -30,
                              left: -30,
                              child: _FloatingIcon(
                                icon: Icons.favorite,
                                color: roseDark,
                                delay: 0.5,
                              ),
                            ),
                            const Positioned(
                              top: -15,
                              right: -30,
                              child: _FloatingIcon(
                                icon: Icons.auto_awesome,
                                color: purpleDark,
                                delay: 1.0,
                              ),
                            ),
                            const Positioned(
                              bottom: -25,
                              right: -25,
                              child: _FloatingIcon(
                                icon: Icons.auto_awesome,
                                color: indigoDark,
                                delay: 1.5,
                                size: 20,
                              ),
                            ),

                            // Main logo
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    roseDark,
                                    purpleDark,
                                    indigoDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: purpleMedium.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 96,
                                color: Colors.white,
                              ),
                            ),

                            // Sparkle badge
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // App name
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              roseDark,
                              purpleDark,
                              indigoDark,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'PreLoved',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline
                        Text(
                          'Treasures Worth Sharing',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Features
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite, size: 16, color: roseDark),
                            const SizedBox(width: 8),
                            Text(
                              'Sustainable • Affordable • Unique',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.auto_awesome, size: 16, color: purpleDark),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // Progress bar
                        SizedBox(
                          width: 250,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    purpleDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _progress < 0.3
                                    ? 'Loading...'
                                    : _progress < 0.7
                                        ? 'Preparing your finds...'
                                        : 'Almost ready...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Tap anywhere to continue',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  fontStyle: FontStyle.italic,
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

              // Bottom gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Animated circle widget
class _AnimatedCircle extends StatefulWidget {
  final double size;
  final Color color;
  final int delay;

  const _AnimatedCircle({
    required this.size,
    required this.color,
    required this.delay,
  });

  @override
  State<_AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<_AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    Future.delayed(Duration(seconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.3 + (_controller.value * 0.1)),
            backgroundBlendMode: BlendMode.multiply,
          ),
        );
      },
    );
  }
}

// Floating icon widget
class _FloatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double delay;
  final double size;

  const _FloatingIcon({
    required this.icon,
    required this.color,
    required this.delay,
    this.size = 24,
  });

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _controller.value),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}

