import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profileviewmodel extends ChangeNotifier {
  bool isLoading = false;

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

      // Fetch users excluding the current user
      final response = await supabaseClient
          .from('users')
          .select('*')
          .eq('id', currentUserId);

      final fetchedUsers =
          List<Map<String, dynamic>>.from(response as List<dynamic>);
    } catch (e) {
      print('Exception: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
