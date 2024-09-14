import 'package:flutter/foundation.dart';
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
      final response = await supabaseClient
          .from('user_communities')
          .select('users(*, product_table(*))')
          .eq('community_id',
              communityId); // Use execute() to get a proper response object

      // Handle the success case
      _usersAndProducts = (response as List).cast<Map<String, dynamic>>();
    } catch (error) {
      _hasError = true;
      _errorMessage = error.toString();
      print('Exception occurred: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
