// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/firebase_options.dart';
import 'package:hushhxtinder/ui/app/chat/chatViewModel.dart';
import 'package:hushhxtinder/ui/app/community/detail/communityDetailViewModel.dart';
import 'package:hushhxtinder/ui/app/connect/connectViewModel.dart';
import 'package:hushhxtinder/ui/app/connect/userdata/userViewModel.dart';
import 'package:hushhxtinder/ui/app/home/homeScreen.dart';
import 'package:hushhxtinder/ui/app/home/homeViewmodel.dart';
import 'package:hushhxtinder/ui/app/product/productViewmodel.dart';
import 'package:hushhxtinder/ui/app/profile/profileViewModel.dart';
import 'package:hushhxtinder/ui/app/settings/settingsViewModel.dart';
import 'package:hushhxtinder/ui/app/vibes/vibesViewModel.dart';
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
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: SupabaseCredentials.APIURL,
    anonKey: SupabaseCredentials.APIKEY,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => ChatViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
        ChangeNotifierProvider(create: (context) => Productviewmodel()),
        ChangeNotifierProvider(create: (context) => ConnectViewModel()),
        ChangeNotifierProvider(create: (context) => CommunityUsersViewModel()),
        ChangeNotifierProvider(create: (context) => VibesViewModel()),
        ChangeNotifierProvider(create: (context) => SettingsViewModel()),
        ChangeNotifierProvider(create: (context) => GetUserViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

///
///
///
///
///
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   log('Handling a background message: ${message.messageId}');
// }

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
      // await prefs.clear();
      // await prefs.setInt('profile_progress', 6);
      // Check if Firebase authentication is valid
      bool isAuthenticated = FirebaseAuth.instance.currentUser != null;
      bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      // log('Loaded onboarding completed: $onboardingCompleted');
      // log('Firebase isAuthenticated: $isAuthenticated');

      // If the user is not authenticated, redirect to the onboarding screen
      if (!isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
        return;
      }

      // Check the user's profile progress
      int profileProgress = prefs.getInt('profile_progress') ?? 0;
      // log('Loaded profile progress: $profileProgress');

      // Determine the next screen based on the profile progress
      Widget nextScreen;
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

      // If onboarding is not completed, redirect to the onboarding screen
      if (onboardingCompleted) {
        // Here, we will clear the back stack to prevent going back to previous screens
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      log('Error during auth and redirect check: $e');
    }
  }
}
// await prefs.clear();