import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        currentPage++;
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

      // Insert new contact
      final response = await supabaseClient.from('contact').insert({
        'userId': currentUserId,
        'contact_userId': contactUserId,
      });
      final response2 = await supabaseClient.from('contact').insert({
        'userId': contactUserId,
        'contact_userId': currentUserId,
      });

      print('UserId added: $contactUserId');
      print('Insert response: $response');
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      isLoading = false;
      // notifyListeners();
      print('Loading state reset and listeners notified.');
    }
  }

  Future<List<String>> fetchContacts() async {
    final supabaseClient = Supabase.instance.client;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No current user ID found.');
    }

    final response = await supabaseClient
        .from('contact')
        .select('contact_userId')
        .eq('userId', currentUserId);

    // Extract user IDs from the response
    final List<String> userIds =
        List<String>.from(response.map((contact) => contact['contact_userId']));

    return userIds;
  }

  Future<List<Map<String, dynamic>>> fetchUserDetails() async {
    final supabaseClient = Supabase.instance.client;
    isLoading = true;
    userDetails = []; // Clear existing user details
    notifyListeners(); // Notify UI of loading state

    try {
      final ids = await fetchContacts();

      if (ids.isEmpty) {
        print('No user IDs found in contacts.');
        return []; // Return an empty list to avoid further processing
      }

      final response = await supabaseClient
          .from('users')
          .select('id,name, images')
          .filter('id', 'in', '(${ids.join(",")})');

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

        return {
          'id': user['id'] as String,
          'name': user['name'] as String,
          'image': firstImageUrl,
        };
      }).toList();

      return userDetails;
    } catch (e) {
      print('Error in fetchUserDetails: $e');
      rethrow; // Rethrow exception for higher-level handling if needed
    } finally {
      isLoading = false;
      notifyListeners(); // Ensure UI is updated after data fetching
    }
  }
}

class ImageData {
  final String imageRes;
  final String name;
  final String role;
  final String companyName;
  final String location;
  final String description;
  final String contactNumber;
  final List<dynamic> products;
  final List<dynamic> passions;
  final String instagram;
  final String linkedin;
  final String twitter;
  final String youtube;
  final String otherlink;
  final String userId;

  ImageData(
      {required this.imageRes,
      required this.name,
      required this.role,
      required this.companyName,
      required this.location,
      required this.description,
      required this.contactNumber,
      required this.products,
      required this.passions,
      required this.instagram,
      required this.linkedin,
      required this.twitter,
      required this.youtube,
      required this.otherlink,
      required this.userId});
}

class CardData {
  final List<List<ImageData>> cards;

  CardData(this.cards);
}
