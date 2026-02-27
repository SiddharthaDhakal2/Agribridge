//import 'package:agribridge/screens/login_screen.dart';
import 'package:agribridge/features/splash/presentation/pages/splash_screen.dart';
import 'package:agribridge/app/theme/theme_data.dart';
import 'package:agribridge/app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      theme: getApplicationTheme(),
      darkTheme: getApplicationDarkTheme(),
      themeMode: themeMode,
      //home:LoginScreen(),
      home: const SplashScreen(),
    );
  }
}
