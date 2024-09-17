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

      // Fetch users excluding the current user
      final response = await supabaseClient
          .from('users')
          .select('*')
          .neq('id', currentUserId)
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
    isLoading = true; // Set loading without notifying
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

      // Call the RPC function and join with product data
      final response = await supabaseClient.rpc('fetch_users_nearby', params: {
        'longitude': currentLon,
        'latitude': currentLat,
        'radius': radiusInMeters,
        'current_user_id': currentUserId
      }).select(
          '*, product_table(*)'); // Include the product data for each user

      // Ensure the response is not null
      final fetchedUsers = List<Map<String, dynamic>>.from(response ?? []);
      print('fetched users are : $fetchedUsers');
      if (fetchedUsers.isNotEmpty) {
        // Process the fetched users and their products
        fetchedUsers.forEach((user) {
          // Convert the product data using fromJson method
          user['products'] = (user['product_table'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        });

        // Shuffle the users and add them to the list
        fetchedUsers.shuffle();
        users.addAll(fetchedUsers);
        currentPage++;
      } else {
        print('No nearby users found.');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      isLoading = false; // Reset the loading state
      notifyListeners(); // Notify listeners only once at the end
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

      // Check if the contact already exists
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

      final response = await supabaseClient.from('contact').insert({
        'chat_id': uuid,
        'userId': currentUserId,
        'contact_userId': contactUserId,
      });
      final response2 = await supabaseClient.from('contact').insert({
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

  Future<List<Map<String, String>>> fetchContacts() async {
    final supabaseClient = Supabase.instance.client;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No current user ID found.');
    }

    final response = await supabaseClient
        .from('contact')
        .select('contact_userId, chat_id')
        .eq('userId', currentUserId);

    final List<Map<String, String>> contacts =
        response.map<Map<String, String>>((contact) {
      log("${contact['chat_id']}");
      return {
        'contact_userId':
            contact['contact_userId'] as String? ?? '', // Handle null case
        'chatId': contact['chat_id'] as String? ?? '', // Handle null case
      };
    }).toList();

    return contacts;
  }

  Future<List<Map<String, dynamic>>> fetchUserDetails() async {
    final supabaseClient = Supabase.instance.client;
    isLoading = true;
    userDetails = [];
    notifyListeners();

    try {
      final contacts = await fetchContacts();

      if (contacts.isEmpty) {
        print('No user IDs found in contacts.');
        return [];
      }

      final userIds =
          contacts.map((contact) => contact['contact_userId']).toList();
      final chatIdMap = {
        for (var contact in contacts)
          contact['contact_userId']: contact['chatId']
      };

      log("ChatId map: $chatIdMap");

      final response = await supabaseClient
          .from('users')
          .select('id, name, images')
          .filter('id', 'in', '(${userIds.join(",")})');

      final List<Map<String, dynamic>> userDetails =
          (response as List<dynamic>).map<Map<String, dynamic>>((user) {
        List<dynamic> imageUrls;
        try {
          imageUrls = user['images'] != null ? jsonDecode(user['images']) : [];
        } catch (e) {
          print('Error decoding images JSON: $e');
          imageUrls = [];
        }

        String firstImageUrl = '';

        if (imageUrls.isNotEmpty && imageUrls[0] is String) {
          firstImageUrl = imageUrls[0];
        }

        final chatId = chatIdMap[user['id']];
        log("Fetched chatId for user ${user['id']}: $chatId");

        if (chatId == null) {
          print("Warning: No chatId found for user ${user['id']}");
        }

        return {
          'contact_userId': user['id'] as String,
          'name': user['name'] as String,
          'image': firstImageUrl,
          'chatId': chatId ?? '',
        };
      }).toList();

      log("User details fetched: ${userDetails.length}");
      return userDetails;
    } catch (e) {
      print('Error in fetchUserDetails: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
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

      final response = await supabaseClient
          .from('users')
          .select('*, product_table(*)')
          .neq('id', currentUserId)
          .range(from, to);

      // Check if response is empty
      if (response.isEmpty) {
        print('No users found.');
        // Update state to reflect no users found
        isLoading = false;
        notifyListeners();
        return;
      }

      // Process the fetched data
      final fetchedUsers = List<Map<String, dynamic>>.from(response);

      // Convert product data using fromJson
      fetchedUsers.forEach((user) {
        user['products'] = (user['product_table'] as List<dynamic>?)
            ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      });

      users.addAll(fetchedUsers);
      users.shuffle();
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



  // Future<void> fetchUsersAndProducts() async {
  //   if (isLoading) return;
  //   isLoading = true;
  //   notifyListeners();

  //   try {
  //     final supabaseClient = Supabase.instance.client;
  //     final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  //     if (currentUserId == null) {
  //       throw Exception('User is not logged in.');
  //     }

  //     final from = currentPage * pageSize;
  //     final to = from + pageSize - 1;

  //     final response = await supabaseClient
  //         .from('users')
  //         .select('*, product_table(*)') // Join users with their products
  //         // .neq('id', currentUserId) // Exclude the current user
  //         .range(from, to);

  //     // Check if response is empty
  //     if (response.isEmpty) {
  //       print('No users found.');
  //       return;
  //     }

  //     // Process the fetched data
  //     final fetchedUsers = List<Map<String, dynamic>>.from(response);

  //     // Convert product data using fromJson
  //     fetchedUsers.forEach((user) {
  //       user['products'] = (user['product_table'] as List<dynamic>?)
  //           ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
  //           .toList();
  //     });

  //     // Update the state with the new users
  //     users.addAll(fetchedUsers);
  //     users.shuffle();
  //     currentPage++;
  //   } catch (e) {
  //     print('Exception: $e');
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> fetchUsersAndProducts() async {
  //   if (isLoading) return;
  //   isLoading = true;
  //   notifyListeners();

  //   try {
  //     final supabaseClient = Supabase.instance.client;
  //     final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  //     if (currentUserId == null) {
  //       throw Exception('User is not logged in.');
  //     }

  //     final from = currentPage * pageSize;
  //     final to = from + pageSize - 1;

  //     // Fetch users excluding the current user
  //     final response = await supabaseClient
  //         .from('users')
  //         .select('*')
  //         // .neq('id', currentUserId)
  //         .range(from, to);

  //     final fetchedUsers =
  //         List<Map<String, dynamic>>.from(response as List<dynamic>);

  //     if (fetchedUsers.isEmpty) {
  //       print('No users found.');
  //     } else {
  //       // Fetch products for each user
  //       for (var user in fetchedUsers) {
  //         user['products'] = await fetchProductsForUser(user['id']);
  //       }

  //       users.addAll(fetchedUsers);
  //       users.shuffle();
  //       currentPage++;
  //     }
  //   } catch (e) {
  //     print('Exception: $e');
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Future<List<Product>> fetchProductsForUser(String userId) async {
  //   final _supabase = Supabase.instance.client;
  //   try {
  //     final response = await _supabase
  //         .from("product_table")
  //         .select()
  //         .eq('userId', userId)
  //         .order('created_at', ascending: true);

  //     log("Response for user $userId: $response"); // Add logging here

  //     if (response != null && response is List<dynamic>) {
  //       final data = response
  //           .map((item) => Product(
  //                 productImageUrl: item['image'],
  //                 productname: item['name'],
  //                 productContent: item['description'],
  //                 productPrice: item['price'],
  //               ))
  //           .toList();

  //       log("Mapped products for user $userId: $data"); // Add logging here

  //       return data;
  //     } else {
  //       log("No products found for user $userId.");
  //       return [];
  //     }
  //   } catch (error) {
  //     log('Error fetching products for user $userId: $error');
  //     return [];
  //   }
  // }