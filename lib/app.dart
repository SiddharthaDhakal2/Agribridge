//import 'package:agribridge/screens/login_screen.dart';
import 'package:agribridge/screens/splash_screen.dart';
import 'package:flutter/material.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home:LoginScreen(),
      home:SplashScreen(),
    );
  }
}