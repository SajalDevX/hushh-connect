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

      // Parse social media JSON object
      Map<String, String>? socialmedia;
      if (data['socialmedia'] != null) {
        socialmedia =
            Map<String, String>.from(json.decode(data['socialmedia']));
      }

      // Parse passions as a list of strings
      List<String>? passions;
      if (data['passions'] != null) {
        passions = List<String>.from(json.decode(data['passions']));
      }

      // Office details stored as a JSON object
      String? officeDetails;
      if (data['office_details'] != null) {
        officeDetails = jsonEncode(data['office_details']);
      }

      // Create a ProfileData object
      profile = ProfileData(
        name: data['name'] ?? 'Unknown',
        imageurl: imageUrls.isNotEmpty ? imageUrls[0] : '',
        homeLoc: data['current_address'] ?? '',
        officeDetails: officeDetails,
        passions: passions,
        socialmedia: socialmedia,
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

  double getProfileCompletionPercentage() {
    if (profile == null) return 0.0;

    int filledFields = 0;
    final totalFields = 6; // Number of fields to check

    if (profile!.name.isNotEmpty) filledFields++;
    if (profile!.imageurl.isNotEmpty) filledFields++;
    if (profile!.homeLoc?.isNotEmpty ?? false) filledFields++;
    if (profile!.officeDetails?.isNotEmpty ?? false) filledFields++;
    if (profile!.socialmedia != null && profile!.socialmedia!.isNotEmpty)
      filledFields++;
    if (profile!.passions != null && profile!.passions!.isNotEmpty)
      filledFields++;

    return (filledFields / totalFields) * 100.0;
  }
}
