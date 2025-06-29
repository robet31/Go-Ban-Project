import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
// import 'onboarding_screen.dart';
// import 'auth/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.forward();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    if (isOnboardingCompleted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi Lottie dengan error handling
            _buildLottieAnimation(),
            const SizedBox(height: 20),
            const Text(
              "GOBAN",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF141E46),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLottieAnimation() {
    try {
      return Lottie.asset(
        'assets/animations/loading.json',
        controller: _controller,
        height: 200,
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..forward();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAnimation();
        },
      );
    } catch (e) {
      return _buildFallbackAnimation();
    }
  }

  Widget _buildFallbackAnimation() {
    return Column(
      children: [
        Image.asset(
          'assets/icon/logo.png',
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 20),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF41B06E)),
        ),
      ],
    );
  }
}