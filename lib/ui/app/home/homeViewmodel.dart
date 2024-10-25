// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hushhxtinder/data/models/productModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class HomeViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, dynamic>> users = [];
  int currentPage = 0;
  static const int pageSize = 10;
  List<Map<String, dynamic>> userDetails = [];

  Future<List<String>> fetchBlockedUsers() async {
    final supabaseClient = Supabase.instance.client;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('User is not logged in.');
    }

    final response = await supabaseClient
        .from('users')
        .select('blocked_users')
        .eq('id', currentUserId)
        .maybeSingle();

    if (response != null && response['blocked_users'] != null) {
      return List<String>.from(response['blocked_users']);
    } else {
      return [];
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

  Future<void> fetchUsers() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      final from = currentPage * pageSize;
      final to = from + pageSize - 1;

      // Fetch blocked users
      final blockedUsers = await fetchBlockedUsers();

      // Fetch users excluding blocked users
      final response = await supabaseClient
          .from('users')
          .select('*')
          .neq('id', currentUserId)
          .not('id', 'in', blockedUsers) // Exclude blocked users
          .range(from, to);

      final fetchedUsers =
      List<Map<String, dynamic>>.from(response as List<dynamic>);

      if (fetchedUsers.isEmpty) {
        print('No users found.');
      } else {
        users.addAll(fetchedUsers);
        users.shuffle();
        currentPage++;
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsersNearby() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners(); // Notify that the loading state has changed

    const double radiusInMiles = 10.0;

    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      // Fetch the current user's position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double currentLat = position.latitude;
      double currentLon = position.longitude;

      const radiusInMeters = radiusInMiles * 1609.34;

      // Fetch blocked users
      final blockedUsers = await fetchBlockedUsers();

      // Call the RPC function and join with product data
      final response = await supabaseClient.rpc('fetch_users_nearby', params: {
        'longitude': currentLon,
        'latitude': currentLat,
        'radius': radiusInMeters,
        'current_user_id': currentUserId
      }).select('*, product_table(*)');

      final fetchedUsers = List<Map<String, dynamic>>.from(response);

      if (fetchedUsers.isNotEmpty) {
        // Exclude blocked users manually after fetching
        final filteredUsers = fetchedUsers.where((user) {
          return !blockedUsers.contains(user['id']);
        }).toList();

        filteredUsers.forEach((user) {
          user['products'] = (user['product_table'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        });

        filteredUsers.shuffle();
        users.addAll(filteredUsers);
        currentPage++;
      } else {
        print('No nearby users found.');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToContact(String contactUserId) async {
    if (isLoading) {
      print('Add to contact request is already in progress.');
      return;
    }

    isLoading = true;

    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('No current user ID found.');
      }

      final existingContact = await supabaseClient
          .from('contact')
          .select('id')
          .eq('userId', currentUserId)
          .eq('contact_userId', contactUserId)
          .maybeSingle();

      if (existingContact != null) {
        print('Contact already exists for user ID: $contactUserId');
        return;
      }

      final uuid = Uuid().v4();
      await supabaseClient.from('contact').insert({
        'chat_id': uuid,
        'userId': currentUserId,
        'contact_userId': contactUserId,
      });
      await supabaseClient.from('contact').insert({
        'chat_id': uuid,
        'userId': contactUserId,
        'contact_userId': currentUserId,
      });
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      isLoading = false;
      // notifyListeners();
      print('Loading state reset and listeners notified.');
    }
  }

  Future<void> fetchUsersAndProducts({bool isReload = false}) async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      // Clear the users list on reload
      if (isReload) {
        users.clear();
        currentPage = 0; // Reset the current page
      }

      final from = currentPage * pageSize;
      final to = from + pageSize - 1;

      // Fetch blocked users
      final blockedUsers = await fetchBlockedUsers();

      // Fetch users and their products, excluding blocked users
      final response = await supabaseClient
          .from('users')
          .select('*, product_table(*)')
          .neq('id', currentUserId)
          .not('id', 'in', blockedUsers) // Exclude blocked users
          .range(from, to);

      if (response.isEmpty) {
        print('No users found.');
        isLoading = false;
        notifyListeners();
        return;
      }

      final fetchedUsers = List<Map<String, dynamic>>.from(response);

      fetchedUsers.forEach((user) {
        user['products'] = (user['product_table'] as List<dynamic>?)
            ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      });

      users.addAll(fetchedUsers);
      users.shuffle();
      print("Size of users is : ${users.length}");
      currentPage++;
    } catch (e) {
      print('Exception: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> followUser(String followingUserId) async {
    if (isLoading) return;
    isLoading = true;

    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('No current user ID found.');
      }

      // Check if the follow relationship already exists
      final existingFollow = await supabaseClient
          .from('likes_table')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('following_id', followingUserId)
          .maybeSingle();

      if (existingFollow != null) {
        print('You are already following user: $followingUserId');
        return;
      }

      // Add a new follow relationship
      final response = await supabaseClient.from('likes_table').insert({
        'follower_id': currentUserId,
        'following_id': followingUserId,
      });

      if (response != null) {
        print('Successfully followed user: $followingUserId');
      }
    } catch (e) {
      print('Error following user: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkAndOpenVibesScreen(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      // Fetch event with start and end times
      final eventResponse = await supabaseClient
          .from('vibes_events')
          .select('id, start_time, end_time')
          .maybeSingle();

      if (eventResponse == null) {
        return false;
      }

      // Get event start and end time from the response
      final eventId = eventResponse['id'];
      final eventStart = DateTime.parse(eventResponse['start_time']);
      final eventEnd = DateTime.parse(eventResponse['end_time']);
      final currentTime = DateTime.now();

      // Check if current time lies between event start and end times
      if (!(currentTime.isAfter(eventStart) &&
          currentTime.isBefore(eventEnd))) {
        print("Check for vibes is active or not: false");
        return false; // Event has ended
      }

      // Check if the user has skipped or completed the event
      final userStatusResponse = await supabaseClient
          .from('vibes_user_status')
          .select('status')
          .eq('user_id', currentUserId)
          .eq('event_id', eventId)
          .maybeSingle();

      if (userStatusResponse != null) {
        final status = userStatusResponse['status'];
        if (status == 'skipped' || status == 'answered') {
          print("User has already skipped or answered the event.");
          return false; // User has already completed or skipped the event
        }
      }

      print("Check for vibes is active or not: true");
      return true; // Event is active and user hasn't skipped or answered
    } catch (e) {
      print('Error checking vibes event: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<int?> fetchActiveVibeEventId() async {
    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      // Fetch event with start and end times
      final eventResponse = await supabaseClient
          .from('vibes_events')
          .select('id, start_time, end_time')
          .maybeSingle();

      if (eventResponse == null) {
        return null; // No active event found
      }

      // Get event start and end time from the response
      final eventId = eventResponse['id'];
      final eventStart = DateTime.parse(eventResponse['start_time']);
      final eventEnd = DateTime.parse(eventResponse['end_time']);
      final currentTime = DateTime.now();

      // Check if current time lies between event start and end times
      if (currentTime.isAfter(eventStart) && currentTime.isBefore(eventEnd)) {
        // Check if the user has skipped or completed the event
        final userStatusResponse = await supabaseClient
            .from('vibes_user_status')
            .select('status')
            .eq('user_id', currentUserId)
            .eq('event_id', eventId)
            .maybeSingle();

        if (userStatusResponse != null) {
          final status = userStatusResponse['status'];
          if (status == 'skipped' || status == 'answered') {
            return null; // User has already completed or skipped the event
          }
        }

        // Return the event ID if it's active and user hasn't skipped or completed
        return eventId;
      } else {
        return null; // Event has not started or has ended
      }
    } catch (e) {
      print('Error fetching active Vibe event: $e');
      return null;
    }
  }


}
