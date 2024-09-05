// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
}
