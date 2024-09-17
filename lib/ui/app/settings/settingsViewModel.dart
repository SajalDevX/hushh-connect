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

  // Get the current "nearby users" preference
  Future<bool> getNearbyUsersPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('nearby_users') ??
        false; // Return false if no value is set
  }
}
