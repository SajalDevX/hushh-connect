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
        await _supabase.from('message').insert(message.toMap());
        notifyListeners();
      } catch (e) {
        print("Error sending message: $e");
      }
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

      userDetails =
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

  /// Method to mark a message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _supabase
          .from('message')
          .update({'mark_as_read': true}).eq('id', messageId);
      notifyListeners(); // Notify listeners to update UI
    } catch (e) {
      print("Error marking message as read: $e");
    }
  }

  Stream<Message?> getLastMessageForChat(String chatId) {
    try {
      // Subscribe to the 'message' table for real-time updates
      final stream = _supabase
          .from('message')
          .stream(primaryKey: [
            'chat_id'
          ]) // Stream changes based on the 'chat_id' column
          .eq('chat_id', chatId)
          .order('created_at', ascending: false)
          .limit(1)
          .map((data) {
            if (data.isNotEmpty) {
              // Parse the last message and return it
              return Message.fromJson(data.first, currentUserId!);
            } else {
              return null; // No message found for this chat
            }
          });

      return stream;
    } catch (e) {
      print("Error setting up real-time stream for chat $chatId: $e");
      return Stream.value(null); // Return a stream with a null value on error
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
