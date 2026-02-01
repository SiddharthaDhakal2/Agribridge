import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribridge/app/app.dart';
import 'package:agribridge/core/services/hive/hive_service.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agribridge/features/dashboard/data/models/profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the adapter before opening boxes
  Hive.registerAdapter(ProfileModelAdapter()); 

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();
  await hiveService.openBoxes();

  // shared pref
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: App(),
    ),
  );
}