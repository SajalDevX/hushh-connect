import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsViewModel extends ChangeNotifier {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final supabaseClient = Supabase.instance.client;

  Future<int?> fetchActiveVibeEventId() async {
    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      final eventResponse = await supabaseClient
          .from('vibes_events')
          .select('id, start_time, end_time')
          .maybeSingle();

      if (eventResponse == null) {
        return null;
      }

      final eventId = eventResponse['id'];
      final eventStart = DateTime.parse(eventResponse['start_time']);
      final eventEnd = DateTime.parse(eventResponse['end_time']);
      final currentTime = DateTime.now();

      if (currentTime.isAfter(eventStart) && currentTime.isBefore(eventEnd)) {
        await supabaseClient
            .from('vibes_user_status')
            .select('status')
            .eq('user_id', currentUserId)
            .eq('event_id', eventId)
            .maybeSingle();

        return eventId;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching active Vibe event: $e');
      return null;
    }
  }

  Future<void> deleteResponseAndStatus() async {
    try {
      int? eventId = await fetchActiveVibeEventId();
      await supabaseClient
          .from('vibes_responses')
          .delete()
          .eq('user_id', currentUserId)
          .eq('event_id', eventId!);
      await supabaseClient
          .from('vibes_user_status')
          .delete()
          .eq('user_id', currentUserId)
          .eq('event_id', eventId);
    } catch (e) {
      print('Error deleting responses and status: $e');
    }
  }

  Future<void> setNearbyUsersPreference(bool isNearbyEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nearby_users', isNearbyEnabled);
    notifyListeners();
  }

  Future<bool> getNearbyUsersPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('nearby_users') ?? false;
  }

  Future<void> deleteUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No user is logged in.');
      }

      await supabaseClient.from('users').delete().eq('id', currentUserId);

      await supabaseClient
          .from('vibes_user_status')
          .delete()
          .eq('user_id', currentUserId);

      await supabaseClient
          .from('vibes_responses')
          .delete()
          .eq('user_id', currentUserId);

      await supabaseClient
          .from('user_communities')
          .delete()
          .eq('user_id', currentUserId);

      await supabaseClient.from('likes_table').delete().eq('id', currentUserId);

      await supabaseClient
          .from('contact')
          .delete()
          .eq('user_id', currentUserId);

      await currentUser.delete();

      notifyListeners();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
