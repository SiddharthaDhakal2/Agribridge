import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
