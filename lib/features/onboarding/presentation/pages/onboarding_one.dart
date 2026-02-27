import 'package:agribridge/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';

import 'onboarding_two.dart';

class OnboardingOne extends StatelessWidget {
  const OnboardingOne({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF123328);
    final subtitleColor = isDarkMode ? Colors.white70 : const Color(0xFF4B5C54);
    final heroCardColor = isDarkMode
        ? const Color(0xFF1A241F)
        : const Color(0xFFEFF6F0);
    final heroBorderColor = isDarkMode ? Colors.white12 : Colors.white;
    final activeDotColor = isDarkMode
        ? const Color(0xFF81C784)
        : const Color(0xFF2E7D32);
    final inactiveDotColor = isDarkMode ? Colors.white24 : Colors.black12;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _goToLogin(context),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode
                          ? const Color(0xFF9CD3B0)
                          : const Color(0xFF1F7A3A),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: heroCardColor,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(color: heroBorderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/agri_logo.png',
                          width: 170,
                          height: 170,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Welcome to AgriBridge',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Connecting farmers and buyers directly\nfor a smarter and fairer agriculture market.',
                      style: TextStyle(
                        fontSize: 16,
                        color: subtitleColor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _IndicatorDot(
                          isActive: true,
                          activeColor: activeDotColor,
                          inactiveColor: inactiveDotColor,
                        ),
                        const SizedBox(width: 8),
                        _IndicatorDot(
                          isActive: false,
                          activeColor: activeDotColor,
                          inactiveColor: inactiveDotColor,
                        ),
                        const SizedBox(width: 8),
                        _IndicatorDot(
                          isActive: false,
                          activeColor: activeDotColor,
                          inactiveColor: inactiveDotColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const OnboardingTwo()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Next', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;

  const _IndicatorDot({
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: isActive ? 22 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
