import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'auth/login_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.repeat(reverse: true);
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 4000));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.status == AuthStatus.initial) {
      int attempts = 0;
      const maxAttempts = 10;
      while (authService.status == AuthStatus.initial && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }
    }

    if (!mounted) return;

    if (authService.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen(initialLocation: null, initialSport: null)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFF0F2027),
                  Color.fromARGB(255, 3, 3, 3),
                  Color.fromARGB(255, 2, 2, 2),
                ],
              ),
            ),
          ),

          // Glowing Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _StarPainter(animationValue: _animationController.value),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glowing pulse behind logo
                        Container(
                          width: screenSize.width * 0.5,
                          height: screenSize.width * 0.5,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulse
                              Container(
                                width: screenSize.width * 0.5,
                                height: screenSize.width * 0.5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1 + _animationController.value * 0.3),
                                      blurRadius: 25 + _animationController.value * 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              // Glassy Logo Container
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: screenSize.width * 0.4,
                                    height: screenSize.width * 0.4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.15),
                                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Image.asset(
                                      'assets/images/2.jpg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Neon Shimmer Text
                        Shimmer.fromColors(
                          baseColor: Colors.cyanAccent,
                          highlightColor: Colors.blueAccent,
                          child: Text(
                            'Sportstix',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Book your favorite matches',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                        ),

                        const SizedBox(height: 40),

                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Particle star painter
class _StarPainter extends CustomPainter {
  final double animationValue;
  _StarPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 60; i++) {
      final x = (size.width * (i / 60)) + 10 * (animationValue - 0.5);
      final y = (size.height * ((i * 13 % 50) / 50)) + 15 * animationValue;
      canvas.drawCircle(Offset(x, y), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => true;
}
