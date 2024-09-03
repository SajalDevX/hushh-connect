import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, dynamic>> users = [];
  int currentPage = 0;
  static const int pageSize = 10;

  Future<void> fetchUsers() async {
    if (isLoading) return; // Prevent multiple calls

    isLoading = true;
    notifyListeners();

    try {
      final supabaseClient = Supabase.instance.client;

      // Calculate range for the current page
      final from = currentPage * pageSize;
      final to = from + pageSize - 1;

      final response =
          await supabaseClient.from('users').select('*').range(from, to);

      // Handle response and check for errors
      final fetchedUsers = List<Map<String, dynamic>>.from(response as List);

      // Convert fetched users to the desired format
      users.addAll(fetchedUsers);
      currentPage++;
    } catch (e) {
      print('Exception: $e');
    } finally {
      isLoading = false;
      notifyListeners();
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
  final List<String> socialMediaLinks;

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
      required this.socialMediaLinks});
}

class CardData {
  final List<List<ImageData>> cards;

  CardData(this.cards);
}
