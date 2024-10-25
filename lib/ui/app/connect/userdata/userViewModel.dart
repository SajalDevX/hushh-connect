import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetUserViewModel extends ChangeNotifier {
  bool isLoading = false;
  ProfileData? profile;
  List<String> imageUrls = [];
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

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

  Future<void> blockUser(String blockedUserId) async {
    final supabaseClient = Supabase.instance.client;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      print("No current user ID found.");
      return;
    }

    try {
      // Fetch the current user's blocked users list
      final response = await supabaseClient
          .from('users')
          .select('blocked_users')
          .eq('id', currentUserId)
          .single();



      List<String> blockedUsers = response['blocked_users'] != null
          ? List<String>.from(response['blocked_users'])
          : [];

      if (!blockedUsers.contains(blockedUserId)) {
        blockedUsers.add(blockedUserId);
      }

      final updateResponse = await supabaseClient
          .from('users')
          .update({'blocked_users': blockedUsers})
          .eq('id', currentUserId);

      final rpcResponse = await supabaseClient.rpc('remove_blocked_user_connections', params: {
        'user_id': currentUserId,
        'blocked_user_id': blockedUserId
      });
    } catch (e) {
      print('Exception in blockUser: $e');
    }
  }

}
