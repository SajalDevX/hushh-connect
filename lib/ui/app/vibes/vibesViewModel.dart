import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VibesViewModel extends ChangeNotifier {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Map<String, dynamic>>> fetchVibesQuestionsWithOptions(
      String vibesId) async {
    final supabaseClient = Supabase.instance.client;

    final response = await supabaseClient
        .from('vibes_questions')
        .select(
            'id, question_text, options') // Assuming options are in JSONB format
        .eq('event_id', vibesId);
    // print("Questions are: $response");
    return List<Map<String, dynamic>>.from(response as List<dynamic>);
  }

  Future<void> updateUserVibesStatus({
    required int eventId,
    required String status,
  }) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final now = DateTime.now()
          .toIso8601String(); // Convert DateTime to ISO 8601 string

      final response = await supabaseClient.from('vibes_user_status').upsert({
        'user_id': currentUserId,
        'event_id': eventId,
        'status': status,
        'timestamp': now, // Use the ISO 8601 string
      });
    } catch (e) {
      print('Error updating user vibes status: $e');
    }
  }

  Future<void> submitVibesAnswers(
      {required List<Map<String, dynamic>> answers}) async {
    final supabaseClient = Supabase.instance.client;
    final now = DateTime.now().toIso8601String();

    // Prepare the responses to be inserted
    final responses = answers
        .map((answer) => {
              'user_id': currentUserId,
              'question_id': answer['question_id'],
              'response': answer['response'],
              'event_id': answer['event_id'],
              'timestamp': now,
            })
        .toList();

    try {
      final response =
          await supabaseClient.from('vibes_responses').insert(responses);

      print('Responses submitted successfully');
    } catch (e) {
      // Log the exception details
      print('Error submitting vibes answers: $e');
    }
  }
}
