import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetUserViewModel extends ChangeNotifier {
  bool isLoading = false;
  ProfileData? profile;
  List<String> imageUrls = [];

  Future<ProfileData?> fetchUserById(String uid) async {
    if (isLoading) return profile;
    try {
      final supabaseClient = Supabase.instance.client;

      final response =
          await supabaseClient.from('users').select().eq('id', uid).single();
      final data = response;
      if (data['images'] != null) {
        imageUrls = List<String>.from(json.decode(data['images']));
      }

      Map<String, String>? socialmedia;
      if (data['socialmedia'] != null) {
        socialmedia =
            Map<String, String>.from(json.decode(data['socialmedia']));
      }

      List<String>? passions;
      if (data['passions'] != null) {
        passions = List<String>.from(json.decode(data['passions']));
      }

      Map<String, dynamic>? officeDetails;
      if (data['office_details'] != null && data['office_details'] is String) {
        officeDetails = jsonDecode(data['office_details']);
      }

      profile = ProfileData(
          uid: data['id'] ?? 'null',
          name: data['name'] ?? 'Unknown',
          images: imageUrls,
          profile_img: imageUrls.isNotEmpty ? imageUrls[0] : '',
          homeLoc: data['current_address'] ?? '',
          officeDetails:
              officeDetails != null ? jsonEncode(officeDetails) : null,
          passions: passions,
          socialmedia: socialmedia,
          email: data['email'] ?? 'Unknown');

      return profile;
    } catch (e) {
      print('Exception: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<ProfileData?> fetchUserById(String uid) async {
  //   final supabase = Supabase.instance.client;

  //   try {
  //     final response = await supabase
  //         .from('profiles')
  //         .select()
  //         .eq('uid', uid)
  //         .single(); // Ensure that only a single row is expected

  //     return ProfileData.fromJson(response);
  //   } catch (e) {
  //     if (e is PostgrestException && e.code == 'PGRST116') {
  //       print('Error: ${e.message}');
  //     }
  //     throw e;
  //   }
  // }
}
