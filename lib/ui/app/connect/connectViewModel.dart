import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectViewModel extends ChangeNotifier {
  bool isLoadingMutual = false; // Loading flag for mutual users
  bool isLoadingFollowing = false; // Loading flag for following users
  bool isLoadingFollowers = false; // Loading flag for followers

  List<Map<String, dynamic>> mutualUsers = [];
  List<Map<String, dynamic>> followingUsers = [];
  List<Map<String, dynamic>> followers = [];

  // Cache to store the fetched users
  final Map<String, List<Map<String, dynamic>>> cache = {
    'mutual': [],
    'following': [],
    'followers': []
  };

  final supabaseClient = Supabase.instance.client;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Log function for convenience
  void log(String message) {
    print('[ConnectViewModel] $message');
  }

  // Fetch mutual users (both current user and the other user follow each other)
  Future<void> fetchMutualUsers() async {
    log('Attempting to fetch mutual users...');

    if (cache['mutual']!.isNotEmpty) {
      log('Using cached mutual users.');
      mutualUsers = cache['mutual']!;
      notifyListeners();
      return; // Use cached data.
    }

    if (isLoadingMutual) {
      log('Mutual users fetch in progress, skipping...');
      return; // Prevent concurrent calls
    }
    if (currentUserId == null) {
      log('No authenticated user found.');
      return; // Check if user is authenticated
    }

    isLoadingMutual = true;
    log('Fetching mutual users from Supabase...');
    notifyListeners();

    try {
      // Assuming 'fetch_mutual_users' RPC returns the list of mutual users
      final response = await supabaseClient.rpc('fetch_mutual_users', params: {
        'current_user_id': currentUserId, // Use the Firebase user ID directly
      });

      if (response != null && response.isNotEmpty) {
        mutualUsers =
            List<Map<String, dynamic>>.from(response as List<dynamic>);
        cache['mutual'] = mutualUsers; // Cache the results
        log('Mutual users fetched successfully.');
      } else {
        log('No mutual users found.');
      }
    } catch (e) {
      log('Error fetching mutual users: $e');
    } finally {
      isLoadingMutual = false;
      notifyListeners();
      log('Mutual user fetch completed.');
    }
  }

  // Fetch users followed by the current user
  Future<void> fetchFollowingUsers() async {
    log('Attempting to fetch following users...');

    if (cache['following']!.isNotEmpty) {
      log('Using cached following users.');
      followingUsers = cache['following']!;
      Future.microtask(() =>
          notifyListeners()); // Defer notification to after the build phase.
      return; // Use cached data.
    }

    if (isLoadingFollowing) {
      log('Following users fetch in progress, skipping...');
      return; // Prevent concurrent calls
    }
    if (currentUserId == null) {
      log('No authenticated user found.');
      return; // Check if user is authenticated
    }

    isLoadingFollowing = true;
    log('Fetching following users from Supabase...');
    notifyListeners();

    try {
      final response = await supabaseClient
          .from('likes_table')
          .select(
              'following_id, users!fk_following(name, images)') // Specify the exact relationship
          .eq('follower_id',
              currentUserId!); // Fetch rows where the current user is the follower

      if (response != null && response.isNotEmpty) {
        followingUsers =
            List<Map<String, dynamic>>.from(response as List<dynamic>);
        cache['following'] = followingUsers; // Cache the results
        log('Following users fetched successfully.');
      } else {
        log('No following users found.');
      }
    } catch (e) {
      log('Error fetching following users: $e');
    } finally {
      isLoadingFollowing = false;
      Future.microtask(() => notifyListeners());
      log('Following user fetch completed.');
    }
  }

  // Fetch users following the current user
  Future<void> fetchFollowers() async {
    log('Attempting to fetch followers...');

    if (cache['followers']!.isNotEmpty) {
      log('Using cached followers.');
      followers = cache['followers']!;
      notifyListeners();
      return; // Use cached data.
    }

    if (isLoadingFollowers) {
      log('Followers fetch in progress, skipping...');
      return; // Prevent concurrent calls
    }
    if (currentUserId == null) {
      log('No authenticated user found.');
      return; // Check if user is authenticated
    }

    isLoadingFollowers = true;
    log('Fetching followers from Supabase...');
    notifyListeners();

    try {
      final response = await supabaseClient
          .from('likes_table')
          .select(
              'follower_id, users!fk_follower(name, images)') // Specify the exact relationship
          .eq('following_id',
              currentUserId!); // Fetch rows where the current user is being followed

      if (response != null && response.isNotEmpty) {
        followers = List<Map<String, dynamic>>.from(response as List<dynamic>);
        cache['followers'] = followers; // Cache the results
        log('Followers fetched successfully.');
      } else {
        log('No followers found.');
      }
    } catch (e) {
      log('Error fetching followers: $e');
    } finally {
      isLoadingFollowers = false;
      notifyListeners();
      log('Follower fetch completed.');
    }
  }

  // Clear cache manually (optional)
  void clearCache() {
    log('Clearing cache...');
    cache['mutual'] = [];
    cache['following'] = [];
    cache['followers'] = [];
    notifyListeners();
    log('Cache cleared.');
  }
}
