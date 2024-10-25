import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'dart:typed_data' as typed_data;

import 'package:syncfusion_flutter_pdf/pdf.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? verificationId;

  // FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // AuthViewModel() {
  //   _initializeFirebaseMessaging();
  // }
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

  Future<void> updateProgress(int progress) async {
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

  Future<void> _saveTokenToDatabase(String? token) async {
    if (token != null) {
      final supabaseClient = supabase.Supabase.instance.client;
      await supabaseClient.from('users').upsert({
        'id': FirebaseAuth.instance.currentUser?.uid,
        'fcm_token': token,
      });
    }
  }

  void _setupFlutterLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Future<void> _showNotification(RemoteMessage message) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'your_channel_id', // Replace with your channel ID
  //     'your_channel_name', // Replace with your channel name
  //     channelDescription: 'your_channel_description', // Optional
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await _flutterLocalNotificationsPlugin.show(
  //     message.notification.hashCode,
  //     message.notification?.title,
  //     message.notification?.body,
  //     platformChannelSpecifics,
  //   );
  // }

  Future<void> verifyPhoneNumber(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    log('Starting phone number verification for: $_phoneNumber');

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          log('Verification completed automatically by system.');

          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
          log('User signed in automatically.');

          isLoading = false;
          notifyListeners();

          if (FirebaseAuth.instance.currentUser != null) {
            await saveUserToSupabase(FirebaseAuth.instance.currentUser);
            log('User saved to Supabase.');
          } else {
            log('Error: FirebaseAuth.instance.currentUser is null after sign-in.');
          }

          await updateProgress(4);
          log('Progress updated to 4.');
        },
        verificationFailed: (FirebaseAuthException error) {
          log('Verification failed: ${error.message}, Code: ${error.code}');
          log('Stack Trace: ${error.stackTrace}');
          isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          this.verificationId = verificationId;
          log('Verification code sent. Verification ID: $verificationId');
          isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('Auto-retrieval timeout. Verification ID: $verificationId');
          isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      log('Exception in verifyPhoneNumber: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (verificationId == null) {
      log('Error: Verification ID is null.');
      return;
    }

    isLoading = true;
    notifyListeners();
    log('Verifying OTP: ${otpController.text} with Verification ID: $verificationId');

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (FirebaseAuth.instance.currentUser != null) {
        await saveUserToSupabase(FirebaseAuth.instance.currentUser);
      } else {
        log('Error: FirebaseAuth.instance.currentUser is null after OTP sign-in.');
      }

      await completeOnboarding();
      await updateProgress(5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified successfully!')),
      );
      final bool isNew = await isNewUser(phoneNumber);
      print("The output of newuser search is : $isNew");
      if (!isNew) {
        updateProgress(11);
        context.go('/main');
      } else {
        context.go("/authLocation");
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Handle OTP verification failure
        log('OTP verification failed: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('OTP verification failed: ${e.message}'),
        ));
      } else {
        log('Exception in verifyOtp: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isNewUser(String phoneNumber) async {
    final supabaseClient = supabase.Supabase.instance.client;

    final response = await supabaseClient
        .from('users')
        .select('phone')
        .eq('phone', phoneNumber)
        .maybeSingle();
    if (response != null) {
      return false;
    } else {
      return true;
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
    updateProgress(6);
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
    updateProgress(9);
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
    updateProgress(8);
  }

  Future<void> uploadImagesToSupabase(List<String> imageUrls) async {
    final supabaseClient = supabase.Supabase.instance.client;
    image_links.addAll(imageUrls);

    final imageLinksJson = jsonEncode(imageUrls);

    await supabaseClient.from('users').upsert({
      'id': FirebaseAuth.instance.currentUser?.uid,
      'images': imageLinksJson,
    });

    updateProgress(10);

    log('Image links saved in JSON format: $imageLinksJson');
  }

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
    updateProgress(11);
  }

  String extractedText = '';

  Future<void> uploadResumeAndExtractText() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        typed_data.Uint8List bytes = await File(filePath).readAsBytes();

        final PdfDocument document = PdfDocument(inputBytes: bytes);
        String content = PdfTextExtractor(document).extractText();
        document.dispose();

        extractedText = content;
        log('Resume text fetched successfully: $content');

        final lines = content.split('\n');
        for (String line in lines) {
          if (line.contains('Experience') || line.contains('Worked at')) {
            _tasks = line;
          } else if (line.contains('Company')) {
            _company = line;
          } else if (line.contains('Role')) {
            _role = line;
          }
        }
        if (company != null && role != null && tasks != null) {
          updateOfficeInfo(
              company: _company ?? '', role: _role ?? '', tasks: _tasks ?? '');
          await uploadOfficeInfoToSupabase();
        } else {
          log('Error: Could not extract company, role, or tasks from resume.');
        }
      } else {
        log('Error: File path is null.');
      }
    } else {
      log('Error: No file selected.');
    }
  }
}
