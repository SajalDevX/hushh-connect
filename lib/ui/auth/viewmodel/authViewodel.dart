import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? verificationId;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  AuthViewModel() {
    _initializeFirebaseMessaging();
  }
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  String? _location;

  String _instagram = '';
  String _twitter = '';
  String _youtube = '';
  String _linkedin = '';
  String _other = '';

  String? _company;
  String? _role;
  String? _tasks;
  final List<String> image_links = [];
  final List<File?> _images = List.generate(6, (_) => null);

  String get instagram => _instagram;
  String get twitter => _twitter;
  String get youtube => _youtube;
  String get linkedin => _linkedin;
  String get other => _other;

  // Getters for the office info
  String? get company => _company;
  String? get role => _role;
  String? get tasks => _tasks;

  String get email => _email;
  String get name => _name;
  String get phoneNumber => _phoneNumber;
  String? get location => _location;

  // Getters for images
  List<File?> get images => _images;

  Future<void> _updateProgress(int progress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('profile_progress', progress);
    log('Profile progress saved: $progress');
  }

  Future<void> completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    log('Onboarding completed set to true');
  }

  void updateOfficeInfo({
    required String company,
    required String role,
    required String tasks,
  }) {
    _company = company;
    _role = role;
    _tasks = tasks;
    notifyListeners();
  }

  void updateEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void updatePhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void updateLocation(String location) {
    _location = location;
    notifyListeners();
  }

  void updateInstagram(String username) {
    _instagram = username;
    notifyListeners();
  }

  void updateTwitter(String username) {
    _twitter = username;
    notifyListeners();
  }

  void updateYouTube(String username) {
    _youtube = username;
    notifyListeners();
  }

  void updateLinkedIn(String username) {
    _linkedin = username;
    notifyListeners();
  }

  void updateOther(String link) {
    _other = link;
    notifyListeners();
  }

  ///
  ///
  ///
  ///
  ///
  ///
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for iOS devices
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
      _setupFlutterLocalNotifications();
      _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);
      _firebaseMessaging.getToken().then(_saveTokenToDatabase);
    } else {
      log('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Received message: ${message.notification?.title}");
      _showNotification(message);
    });
  }

  ///
  ///
  ///
  ///
  ///
  Future<void> _saveTokenToDatabase(String? token) async {
    if (token != null) {
      final supabaseClient = supabase.Supabase.instance.client;
      await supabaseClient.from('users').upsert({
        'id': FirebaseAuth.instance.currentUser?.uid,
        'fcm_token': token,
      });
    }
  }

  ///
  ///
  ///
  ///
  ///
  // Setup Flutter Local Notifications
  void _setupFlutterLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  ///
  ///
  ///
  ///
  ///
  ///
  // Show notification when app is in foreground
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Replace with your channel ID
      'your_channel_name', // Replace with your channel name
      channelDescription: 'your_channel_description', // Optional
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  Future<void> verifyPhoneNumber(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumber,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
        isLoading = false;
        notifyListeners();
        await saveUserToSupabase(FirebaseAuth.instance.currentUser);
        await _updateProgress(4); // Update to correct progress value
      },
      verificationFailed: (FirebaseAuthException error) {
        log(error.toString());
        isLoading = false;
        notifyListeners();
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        this.verificationId = verificationId;
        isLoading = false;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        log("Auto Retrieval timeout");
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (verificationId == null) {
      log("Verification ID is null");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await saveUserToSupabase(FirebaseAuth.instance.currentUser);
      await completeOnboarding();
      await _updateProgress(5);
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserToSupabase(User? firebaseUser) async {
    if (firebaseUser == null) {
      log("Firebase user is null, cannot save to Supabase");
      return;
    }

    final supabaseClient = supabase.Supabase.instance.client;

    await supabaseClient.from('users').upsert({
      'id': firebaseUser.uid,
      'name': _name,
      'phone': firebaseUser.phoneNumber,
      'email': _email,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateLocationInProfile() async {
    if (_location == null) {
      log("Location is null, cannot update profile");
      return;
    }

    final supabaseClient = supabase.Supabase.instance.client;
    await supabaseClient.from('users').upsert({
      'id': FirebaseAuth.instance.currentUser?.uid,
      'current_address': _location,
    });
    _updateProgress(6);
  }

  Future<void> uploadSocialMediaLinksToSupabase() async {
    final supabaseClient = supabase.Supabase.instance.client;

    final linksJson = jsonEncode({
      'instagram': _instagram,
      'twitter': _twitter,
      'youtube': _youtube,
      'linkedin': _linkedin,
      'other': _other,
    });
    await supabaseClient.from('users').upsert({
      'id': FirebaseAuth.instance.currentUser?.uid,
      'socialmedia': linksJson,
    });
    _updateProgress(7);
  }

  Future<void> uploadOfficeInfoToSupabase() async {
    final supabaseClient = supabase.Supabase.instance.client;
    final officeInfoJson = jsonEncode({
      'company': _company,
      'role': _role,
      'tasks': _tasks,
    });
    await supabaseClient.from('users').upsert({
      'id': FirebaseAuth.instance.currentUser?.uid,
      'office_details': officeInfoJson,
    });
    _updateProgress(8);
  }

  Future<void> uploadImagesToSupabase(List<String> imageUrls) async {
    final supabaseClient = supabase.Supabase.instance.client;
    image_links.addAll(imageUrls);

    final imageLinksJson = jsonEncode(imageUrls);

    await supabaseClient.from('users').upsert({
      'id': FirebaseAuth.instance.currentUser?.uid,
      'images': imageLinksJson,
    });

    _updateProgress(9);

    log('Image links saved in JSON format: $imageLinksJson');
  }

  // Method to add image to ViewModel
  void addImage(File image, int index) {
    if (index >= 0 && index < _images.length) {
      _images[index] = image;
      notifyListeners();
    }
  }

  Future<void> updatePassions(List<String> passions) async {
    final supabaseClient = supabase.Supabase.instance.client;

    // Convert the list of image URLs to JSON format
    final imageLinksJson = jsonEncode(passions);

    // Store the JSON of image links in the Supabase database
    await supabaseClient.from('users').upsert({
      'id': FirebaseAuth.instance.currentUser?.uid,
      'passions': imageLinksJson,
    });
    _updateProgress(10);
  }
}
