import 'package:agribridge/app/routes/app_routes.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:agribridge/core/services/hive/hive_service.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/features/dashboard/data/models/profile_model.dart';
import 'package:agribridge/features/dashboard/presentation/pages/button_navigation.dart';
import 'package:agribridge/features/onboarding/presentation/pages/onboarding_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    final startedAt = DateTime.now();

    try {
      await ApiEndpoints.initialize();

      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(ProfileModelAdapter());
      }

      final hiveService = HiveService();
      await hiveService.init();
    } catch (_) {
      // Continue with app flow even if startup cache initialization fails.
    }

    final elapsed = DateTime.now().difference(startedAt);
    const minSplashDuration = Duration(seconds: 3);
    final waitDuration = minSplashDuration - elapsed;
    if (waitDuration > Duration.zero) {
      await Future.delayed(waitDuration);
    }

    if (!mounted) return;

    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      AppRoutes.pushReplacement(context, const ButtonNavigation());
    } else {
      AppRoutes.pushReplacement(context, const OnboardingOne());
    }
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
