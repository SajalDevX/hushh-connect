import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/supabaseCredentials.dart';
import 'package:hushhxtinder/ui/app/chat/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatViewModel extends ChangeNotifier {
  final _supabase = SupabaseCredentials.supabaseClient;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late StreamSubscription<List<Map<String, dynamic>>> chatSubscription;
  List<Conversation> chats = [];
  List<Map<String, dynamic>> userDetails = [];
  bool isLoading = false;

  /// Stream to fetch messages for a specific chat in real-time
  Stream<List<Message>> getMessagesForChat(String chatId) {
    return _supabase
        .from('message')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((maps) {
      return maps
          .map((item) => Message.fromJson(item, currentUserId!))
          .toList();
    });
  }

  /// Method to send a message
  Future<void> sendMessage(String content, String userTo, String chatId) async {
    if (currentUserId != null) {
      final message = Message.create(
        content: content,
        userFrom: currentUserId!,
        userTo: userTo,
        chatId: chatId,
      );
      try {
        // Insert message into the message table
        await _supabase.from('message').insert(message.toMap());

        // Prepare JSONB data to update in contact table
        final lastMessageData = {
          'message': content,
          'time_sent': DateTime.now().toUtc().toIso8601String(),
          'user_from': currentUserId!,
        };

        // Update the last_message column in the contact table
        await _supabase
            .from('contact')
            .update({'last_message': lastMessageData}).eq('chat_id', chatId);

        notifyListeners();
      } catch (e) {
        print("Error sending message or updating contact: $e");
      }
    }
  }

  Stream<List<Map<String, dynamic>>> fetchSortedUserDetailsWithLastMessage() {
    final supabaseClient = Supabase.instance.client;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No current user ID found.');
    }

    // Creating a stream that listens to the `contact` table changes
    return supabaseClient
        .from('contact')
        .stream(primaryKey: ['contact_userId'])
        .eq('userId', currentUserId)
        .asyncMap((contacts) async {
      final userIds = contacts.map((contact) => contact['contact_userId']).toList();
      final chatIdMap = {
        for (var contact in contacts)
          contact['contact_userId']: contact['chat_id']
      };

      if (userIds.isEmpty) {
        print('No user IDs found in contacts.');
        return <Map<String, dynamic>>[]; // Return empty list if no contacts
      }

      // Fetch user details from `users` table
      final response = await supabaseClient
          .from('users')
          .select('id, name, images')
          .filter('id', 'in', '(${userIds.join(",")})');

      // Ensure response is cast correctly
      final List<Map<String, dynamic>> userDetails = (response as List<dynamic>).map<Map<String, dynamic>>((user) {
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

        // Handle null for lastMessage safely
        final contact = contacts.firstWhere(
              (contact) => contact['contact_userId'] == user['id'],
          orElse: () => <String, dynamic>{},
        );
        final lastMessage = contact['last_message'] ?? {}; // Default to empty map if null

        // Safely retrieve the time_sent field from last_message
        final lastMessageTime = lastMessage['time_sent'] != null
            ? lastMessage['time_sent']
            : DateTime.now().toIso8601String(); // Use current time if time_sent is null

        return {
          'contact_userId': user['id'] as String,
          'name': user['name'] as String,
          'image': firstImageUrl,
          'chatId': chatId ?? '',
          'last_message': lastMessage, // Safely handle lastMessage being null
          'last_message_time': lastMessageTime, // Capture time_sent or fallback to current time
        };
      }).toList();

      // Sort by last message time
      userDetails.sort((a, b) {
        DateTime timeA = DateTime.parse(a['last_message_time']);
        DateTime timeB = DateTime.parse(b['last_message_time']);
        return timeB.compareTo(timeA); // Sort in descending order
      });

      return userDetails;
    });
  }


  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _supabase
          .from('message')
          .update({'mark_as_read': true}).eq('id', messageId);
      notifyListeners();
    } catch (e) {
      print("Error marking message as read: $e");
    }
  }

  Future<void> sendPushNotification(String fcmToken, String message) async {
    const String serverKey = 'AIzaSyC7MVIeqKN8fI_cB9DdzWbcKRZ6PdNcfUs';

    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': 'New Message',
            'body': message,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Error sending notification: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}

class Conversation {
  final String id;
  final String? lastMessage;
  final DateTime lastUpdated;

  Conversation({
    required this.id,
    this.lastMessage,
    required this.lastUpdated,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      lastMessage: json['last_message'] != null
          ? json['last_message']['content'] as String
          : null,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_message': lastMessage,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
