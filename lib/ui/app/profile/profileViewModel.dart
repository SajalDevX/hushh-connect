import 'dart:convert'; // Import to handle JSON decoding
import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileViewModel extends ChangeNotifier {
  bool isLoading = false;
  ProfileData? profile;

  Future<ProfileData?> fetchUser() async {
    if (isLoading) return profile;

    isLoading = true;
    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      final response = await supabaseClient
          .from('users')
          .select()
          .eq('id', currentUserId)
          .single(); // Use single() to fetch a single row

      final data = response;

      // Parse the image URLs from the JSON string
      List<String> imageUrls = [];
      if (data['images'] != null) {
        imageUrls = List<String>.from(json.decode(data['images']));
      }

      // Create a ProfileData object
      profile = ProfileData(
        name: data['name'] ?? 'Unknown',
        imageurl: imageUrls.isNotEmpty ? imageUrls[0] : '',
      );

      return profile;
    } catch (e) {
      print('Exception: $e');
      return null;
    } finally {
      isLoading = false;
      // Call notifyListeners() outside of the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}
