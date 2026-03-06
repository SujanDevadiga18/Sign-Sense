import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'screens/camera_sign_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/text_translation_screen.dart';
import 'screens/voice_input_screen.dart';
import 'services/sign_sense_provider.dart';

void main() {
  runApp(const SignSenseApp());
}

class SignSenseApp extends StatelessWidget {
  const SignSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignSenseProvider(),
      child: Consumer<SignSenseProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'SignSense AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: provider.themeMode,
            initialRoute: SplashScreen.routeName,
            routes: {
              SplashScreen.routeName: (_) => const SplashScreen(),
              OnboardingScreen.routeName: (_) => const OnboardingScreen(),
              HomeScreen.routeName: (_) => const HomeScreen(),
              TextTranslationScreen.routeName: (_) => const TextTranslationScreen(),
              VoiceInputScreen.routeName: (_) => const VoiceInputScreen(),
              CameraSignScreen.routeName: (_) => const CameraSignScreen(),
              HistoryScreen.routeName: (_) => const HistoryScreen(),
              ProfileScreen.routeName: (_) => const ProfileScreen(),
              EmergencyScreen.routeName: (_) => const EmergencyScreen(),
            },
          );
        },
      ),
    );
  }
}

