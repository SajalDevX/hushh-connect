import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hushhxtinder/data/models/productModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityUsersViewModel with ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _usersAndProducts = [];

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get usersAndProducts => _usersAndProducts;

  CommunityUsersViewModel();

  Future<void> fetchUsersAndProductsInCommunity(int communityId) async {
    final supabaseClient = Supabase.instance.client;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // Fetch users and their products based on the community ID
      final response = await supabaseClient
          .from('user_communities')
          .select('users(*, product_table(*))')
          .eq('community_id', communityId);

      // Map the response data into a list of users and their products
      _usersAndProducts = List<Map<String, dynamic>>.from(response);

      // Parse product data for each user
      _usersAndProducts.forEach((user) {
        user['products'] = (user['product_table'] as List<dynamic>?)
            ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      });

      // log("Fetched users and products: ${usersAndProducts}");
    } catch (error) {
      _hasError = true;
      _errorMessage = error.toString();
      log('Error fetching users and products: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
