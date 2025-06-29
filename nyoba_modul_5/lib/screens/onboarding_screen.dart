import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
// import 'auth/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color backgroundColor = const Color(0xFFFFF5E0);
  final Color primaryColor = const Color(0xFF41B06E);
  final Color textColor = const Color(0xFF141E46);

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Manage your Task',
      'description': 'Organize all your to-dos in lists and projects. Color tag them to set priorities and categories.',
      'image': 'assets/animations/onboarding1.json',
    },
    {
      'title': 'Work on Time',
      'description': 'Plan and complete your tasks efficiently and stay focused.',
      'image': 'assets/animations/onboarding2.json',
    },
    {
      'title': 'Get reminder on time',
      'description': 'Receive timely reminders so you never miss a thing.',
      'image': 'assets/animations/onboarding3.json',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animasi Lottie dengan error handling
                        _buildLottieAnimation(index),
                        const SizedBox(height: 40),
                        Text(
                          onboardingData[index]['title']!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          onboardingData[index]['description']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor.withOpacity(0.7),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indikator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? primaryColor : textColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Tombol
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage != onboardingData.length - 1
                      ? TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == onboardingData.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      _currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLottieAnimation(int index) {
    try {
      return Lottie.asset(
        onboardingData[index]['image']!,
        height: 300,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage(index);
        },
      );
    } catch (e) {
      return _buildFallbackImage(index);
    }
  }

  Widget _buildFallbackImage(int index) {
    return Image.asset(
      'assets/images/onboarding${index + 1}.png', // Pastikan ada gambar fallback
      height: 300,
      fit: BoxFit.contain,
    );
  }
}