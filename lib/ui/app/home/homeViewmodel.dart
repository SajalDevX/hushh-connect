// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hushhxtinder/data/models/productModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class HomeViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, dynamic>> users = [];
  int currentPage = 0;
  static const int pageSize = 10;
  List<Map<String, dynamic>> userDetails = []; // Define userDetails here

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

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double currentLat = position.latitude;
      double currentLon = position.longitude;

      const radiusInMeters = radiusInMiles * 1609.34;

      final response = await supabaseClient.rpc('fetch_users_nearby', params: {
        'longitude': currentLon,
        'latitude': currentLat,
        'radius': radiusInMeters,
        'current_user_id': currentUserId
      });

      final fetchedUsers = List<Map<String, dynamic>>.from(response ?? []);

      if (fetchedUsers.isNotEmpty) {
        fetchedUsers.shuffle();
        users.addAll(fetchedUsers);
        currentPage++;
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

      // print('UserId added: $contactUserId');
      // print('Insert response: $response');
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

  Future<void> fetchUsersAndProducts() async {
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

      // Fetch users with their associated products in a single query
      final response = await supabaseClient
          .from('users')
          .select('*, product_table(*)') // Join users with their products
          // .neq('id', currentUserId) // Exclude the current user
          .range(from, to);

      // Check if response is empty
      if (response == null || response.isEmpty) {
        print('No users found.');
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

      // Update the state with the new users
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
}
