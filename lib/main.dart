// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hushhxtinder/firebase_options.dart';
import 'package:hushhxtinder/ui/app/chat/chatViewModel.dart';
import 'package:hushhxtinder/ui/app/community/detail/communityDetailViewModel.dart';
import 'package:hushhxtinder/ui/app/connect/connectScreen.dart';
import 'package:hushhxtinder/ui/app/connect/connectViewModel.dart';
import 'package:hushhxtinder/ui/app/connect/userdata/userDetailScreen.dart';
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
import 'package:hushhxtinder/ui/auth/authResumeScreen.dart';
import 'package:hushhxtinder/ui/auth/authSocialMediaScreen.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/data/supabaseCredentials.dart';
import 'package:hushhxtinder/ui/onboarding/onBoardingScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links2/uni_links.dart';

void main() async {
  await dotenv.load(fileName: "lib/assets/.env");
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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/authName',
        builder: (context, state) => const AuthNameScreen(),
      ),
      GoRoute(
        path: '/authEmail',
        builder: (context, state) => const AuthEmailScreen(),
      ),
      GoRoute(
        path: '/authPhone',
        builder: (context, state) => const AuthPhoneScreen(),
      ),
      GoRoute(
        path: '/authOtp',
        builder: (context, state) => const AuthOtpScreen(),
      ),
      GoRoute(
        path: '/authResume',
        builder: (context, state) => const AuthResumeScreen(),
      ),
      GoRoute(
        path: '/authLocation',
        builder: (context, state) => const AuthCurrentLocation(),
      ),
      GoRoute(
        path: '/authSocialMedia',
        builder: (context, state) => const AuthSocialMediaScreen(),
      ),
      GoRoute(
        path: '/authOffice',
        builder: (context, state) => const AuthOfficeScreen(),
      ),
      GoRoute(
        path: '/authPhotos',
        builder: (context, state) => const AuthPhotosScreen(),
      ),
      GoRoute(
        path: '/authPassions',
        builder: (context, state) => const AuthPassionsScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => MainScreen(),
      ),
      GoRoute(
        path: '/connect',
        builder: (context, state) => ConnectScreen(),
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) {
          final String? uid = state.pathParameters['uid'];
          log('Navigating to profile with uid: $uid'); // Debug log
          if (uid == null) {
            return const Scaffold(
              body: Center(child: Text('User ID not found')),
            );
          }
          return UserProfileDetailScreen(
            uid: uid,
            onMessageClick: () {},
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _checkAuthAndRedirect(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isAuthenticated = FirebaseAuth.instance.currentUser != null;
      bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      int profileProgress = prefs.getInt('profile_progress') ?? 0;
      // await prefs.clear();
      final Uri? initialUri = await getInitialUri();
      if (initialUri != null && initialUri.pathSegments.isNotEmpty) {
        log('Deep link detected: ${initialUri.toString()}');

        if (initialUri.pathSegments.first == 'profile' &&
            initialUri.pathSegments.length >= 2) {
          final uid = initialUri.pathSegments[1];
          log('Deep link UID: $uid');

          setState(() {});
          context.go('/profile/$uid');
          return;
        }
      }

      if (!isAuthenticated) {
        context.go('/onboarding');
        return;
      }

      if (!onboardingCompleted) {
        context.go('/onboarding');
        return;
      }

      switch (profileProgress) {
        case 1:
          context.go('/authName');
          break;
        case 2:
          context.go('/authEmail');
          break;
        case 3:
          context.go('/authPhone');
          break;
        case 4:
          context.go('/authOtp');
          break;
        case 5:
          context.go('/authLocation');
          break;
        case 6:
          context.go('/authResume');
          break;
        case 7:
          context.go('/authOffice');
          break;
        case 8:
          context.go('/authSocialMedia');
          break;
        case 9:
          context.go('/authPhotos');
          break;
        case 10:
          context.go('/authPassions');
          break;
        default:
          context.go('/main');
      }
    } catch (e) {
      log('Error during auth and redirect check: $e');
      // Navigate to an error screen or main screen as a fallback
      context.go('/main');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect(
        context); // Trigger deep link check and navigation in initState
  }

  @override
  Widget build(BuildContext context) {
    _checkAuthAndRedirect(context);
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
