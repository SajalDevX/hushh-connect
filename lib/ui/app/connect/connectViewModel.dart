import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectViewModel extends ChangeNotifier {
  bool isLoadingMutual = false;
  bool isLoadingFollowing = false;
  bool isLoadingFollowers = false;

  List<Map<String, dynamic>> mutualUsers = [];
  List<Map<String, dynamic>> followingUsers = [];
  List<Map<String, dynamic>> followers = [];

  final supabaseClient = Supabase.instance.client;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  void log(String message) {
    print('[ConnectViewModel] $message');
  }

  Future<void> fetchFollowingUsers() async {
    log('Attempting to fetch following users...');

    if (isLoadingFollowing || currentUserId == null) return;

    isLoadingFollowing = true;
    notifyListeners();

    try {
      final response = await supabaseClient
          .from('likes_table')
          .select('following_id, users!fk_following(name, images)')
          .eq('follower_id', currentUserId!);

      followingUsers = List<Map<String, dynamic>>.from(response);
      log('Following users fetched successfully.');
    } catch (e) {
      log('Error fetching following users: $e');
    } finally {
      isLoadingFollowing = false;
      notifyListeners();
    }
  }

  Future<void> fetchMutualUsers() async {
    log('Attempting to fetch mutual users...');

    if (isLoadingMutual || currentUserId == null) {
      log('Already loading or no current user ID.');
      return;
    }

    isLoadingMutual = true;
    notifyListeners();

    try {
      final response =
          await supabaseClient.rpc('fetch_mutual_users_by_varchar', params: {
        'current_user_id': currentUserId,
      });

      if (response is List<dynamic>) {
        if (response.isNotEmpty) {
          log('Fetched mutual users successfully.');
          mutualUsers = List<Map<String, dynamic>>.from(response);
        } else {
          log('No mutual users found.');
        }
      } else {
        log('Unexpected response format: $response');
      }
    } catch (e) {
      log('Error fetching mutual users: $e');
    } finally {
      isLoadingMutual = false;
      notifyListeners();
    }
  }

  Future<void> fetchFollowers() async {
    log('Attempting to fetch followers...');

    if (isLoadingFollowers || currentUserId == null) return;

    isLoadingFollowers = true;
    notifyListeners();

    try {
      final response = await supabaseClient
          .from('likes_table')
          .select('follower_id, users!fk_follower(name, images)')
          .eq('following_id', currentUserId!);

      followers = List<Map<String, dynamic>>.from(response);
      log('Followers fetched successfully.');
    } catch (e) {
      log('Error fetching followers: $e');
    } finally {
      isLoadingFollowers = false;
      notifyListeners();
    }
  }
}
