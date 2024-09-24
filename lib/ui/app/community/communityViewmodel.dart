import 'package:firebase_auth/firebase_auth.dart';
import 'package:hushhxtinder/data/models/community_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityViewModel {
  final SupabaseClient supabaseClient;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  CommunityViewModel(this.supabaseClient);

  // Future<List<Community>> fetchAllCommunities() async {
  //   final response = await supabaseClient
  //       .from('communities')
  //       .select('id, name, description, image, created_at')
  //       .order('created_at', ascending: false);

  //   return (response as List)
  //       .map((community) => Community.fromJson(community))
  //       .toList();
  // }
  Stream<List<Community>> streamAllCommunities() {
    // This assumes you have a 'communities' table in your Supabase database
    return supabaseClient.from('communities').stream(primaryKey: ['id']).map(
        (data) => data.map((item) => Community.fromJson(item)).toList());
  }

  Future<void> joinCommunity(int communityId) async {
    final existingUserResponse = await supabaseClient
        .from('user_communities')
        .select('*')
        .eq('user_id', currentUserId)
        .eq('community_id', communityId);

    if ((existingUserResponse as List).isEmpty) {
      await supabaseClient.from('user_communities').insert({
        'user_id': currentUserId,
        'community_id': communityId,
      });
    }
  }

  Future<bool> isUserInCommunity(int communityId) async {
    final response = await supabaseClient
        .from('user_communities')
        .select(
            'user_id') // or select 'community_id', since there is no 'id' column
        .eq('user_id', currentUserId)
        .eq('community_id', communityId);

    return (response as List).isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> fetchCommunityUsers(
      int communityId) async {
    final response = await supabaseClient
        .from('user_communities')
        .select('users(id, name, image)')
        .eq('community_id', communityId);

    return (response as List).cast<Map<String, dynamic>>();
  }
}
