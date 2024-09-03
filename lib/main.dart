// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/firebase_options.dart';
import 'package:hushhxtinder/ui/app/home/homeScreen.dart';
import 'package:hushhxtinder/ui/app/home/homeViewmodel.dart';
import 'package:hushhxtinder/ui/auth/authEmailScreen.dart';
import 'package:hushhxtinder/ui/auth/authHomeLocationScreen.dart';
import 'package:hushhxtinder/ui/auth/authNameScreen.dart';
import 'package:hushhxtinder/ui/auth/authOfficeScreen.dart';
import 'package:hushhxtinder/ui/auth/authOtpScreen.dart';
import 'package:hushhxtinder/ui/auth/authPassionsScreen.dart';
import 'package:hushhxtinder/ui/auth/authPhoneScreen.dart';
import 'package:hushhxtinder/ui/auth/authPhotosScreen.dart';
import 'package:hushhxtinder/ui/auth/authSocialMediaScreen.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/data/supabaseCredentials.dart';
import 'package:hushhxtinder/ui/onboarding/onBoardingScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: SupabaseCredentials.APIURL,
    anonKey: SupabaseCredentials.APIKEY,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _checkAuthAndRedirect(context);
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _checkAuthAndRedirect(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isAuthenticated = FirebaseAuth.instance.currentUser != null;
      bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      log('Loaded onboarding completed: $onboardingCompleted'); // Debug log
      // await prefs.clear();
      if (!onboardingCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
        return;
      }

      int profileProgress = prefs.getInt('profile_progress') ?? 0;
      log('Loaded profile progress: $profileProgress'); // Debug log

      Widget nextScreen;
      if (!isAuthenticated) {
        nextScreen = const OnboardingScreen();
      } else {
        switch (profileProgress) {
          case 1:
            nextScreen = const AuthNameScreen();
            break;
          case 2:
            nextScreen = const AuthEmailScreen();
            break;
          case 3:
            nextScreen = const AuthPhoneScreen();
            break;
          case 4:
            nextScreen = const AuthOtpScreen();
            break;
          case 5:
            nextScreen = const AuthCurrentLocation();
            break;
          case 6:
            nextScreen = const AuthSocialMediaScreen();
            break;
          case 7:
            nextScreen = const AuthOfficeScreen();
            break;
          case 8:
            nextScreen = const AuthPhotosScreen();
            break;
          case 9:
            nextScreen = const AuthPassionsScreen();
            break;
          default:
            nextScreen = MainScreen();
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } catch (e) {
      log('Error during auth and redirect check: $e');
    }
  }
}
