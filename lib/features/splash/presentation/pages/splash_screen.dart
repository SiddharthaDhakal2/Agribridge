import 'package:agribridge/app/routes/app_routes.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/features/dashboard/presentation/pages/home_screen.dart';
import 'package:agribridge/features/onboarding/presentation/pages/onboarding_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      // check if user is already logged in
      final userSessionService = ref.read(userSessionServiceProvider);
      final isLoggedIn = userSessionService.isLoggedIn();

      if (isLoggedIn) {
        AppRoutes.pushReplacement(context, const HomeScreen());
      } else {
        AppRoutes.pushReplacement(context, const OnboardingOne());
      }

      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (_) => const OnboardingOne()),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/agri_logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              "AgriBridge",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F3A4D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}