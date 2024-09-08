// ignore_for_file: file_names, avoid_print, unnecessary_null_comparison

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hushhxtinder/data/supabaseCredentials.dart';
// import 'package:hushhxtinder/ui/app/chat/message.dart';

// class ChatViewModel extends ChangeNotifier {
//   final _supabase = SupabaseCredentials.supabaseClient;
//   final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

//   Stream<List<Message>> getMessagesForChat(String chatId) {
//     return _supabase
//         .from('message')
//         .stream(primaryKey: ['id'])
//         .eq('chat_id', chatId)
//         .order('created_at', ascending: true)
//         .map((maps) {
//           return maps
//               .map((item) => Message.fromJson(item, currentUserId!))
//               .toList();
//         });
//   }

//   Future<void> sendMessage(String content, String userTo, String chatId) async {
//     if (userTo != null && currentUserId != null) {
//       final message = Message.create(
//           content: content,
//           userFrom: currentUserId!,
//           userTo: userTo,
//           chatId: chatId);
//       try {
//         await _supabase.from('message').insert(message.toMap());
//         notifyListeners();
//       } catch (e) {
//         print("Error sending message: $e");
//       }
//     }
//   }

//   Future<void> markMessageAsRead(String messageId) async {
//     try {
//       await _supabase
//           .from('message')
//           .update({'mark_as_read': true}).eq('id', messageId);
//     } catch (e) {
//       print("Error marking message as read: $e");
//     }
//   }
// }
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/supabaseCredentials.dart';
import 'package:hushhxtinder/ui/app/chat/message.dart';

class Conversation {
  final String id;
  final String? lastMessage;
  final DateTime lastUpdated;

  Conversation({
    required this.id,
    this.lastMessage,
    required this.lastUpdated,
  });

  // Factory method to create a Conversation object from a JSON map
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      lastMessage: json['last_message'] != null
          ? json['last_message']['content'] as String
          : null,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  // Method to convert a Conversation object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_message': lastMessage,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class ChatViewModel extends ChangeNotifier {
  final _supabase = SupabaseCredentials.supabaseClient;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late StreamSubscription<List<Map<String, dynamic>>> chatSubscription;
  List<Conversation> chats = [];

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
        notifyListeners(); // Notify listeners to update UI
      } catch (e) {
        print("Error sending message: $e");
      }
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

  Future<Message?> getLastMessageForChat(String chatId) async {
    try {
      final response = await _supabase
          .from('message')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: false)
          .limit(1);

      final data = response as List<dynamic>;
      if (data.isNotEmpty) {
        // Parse the last message and return it
        return Message.fromJson(data.first, currentUserId!);
      } else {
        return null; // No message found for this chat
      }
    } catch (e) {
      print("Error fetching last message for chat $chatId: $e");
      return null;
    }
  }

  /// Method to update chats in real-time
  Future<void> updateChatsInRealtime({Function()? setState}) async {
    chatSubscription = _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_updated', ascending: false)
        .listen((event) {
          // Sort the chats based on the last message or last updated time
          event.sort((a, b) => b['last_message'] == null
              ? b['last_updated'].compareTo(a['last_updated'])
              : DateTime.fromMillisecondsSinceEpoch(
                      b['last_message']['created_at'])
                  .compareTo(a['last_message'] == null
                      ? a['last_updated']
                      : DateTime.fromMillisecondsSinceEpoch(
                          a['last_message']['created_at'])));

          // Convert the fetched data to a list of Conversation objects
          chats = event.map((e) => Conversation.fromJson(e)).toList();
          log(chats.map((e) => e.toJson()).toList().toString());

          // Update UI if setState is provided
          if (setState != null) {
            setState();
          }

          // Notify listeners to update the UI
          notifyListeners();
        });
  }

  /// Method to fetch chats from the database
  Future<List<Conversation>> getChats() async {
    try {
      final response = await _supabase.from('conversations').select();
      final data = response as List;
      chats = data.map((e) => Conversation.fromJson(e)).toList();
      notifyListeners();
      return chats;
    } catch (e) {
      print("Exception fetching chats: $e");
    }
    return [];
  }

  @override
  void dispose() {
    chatSubscription.cancel(); // Cancel the subscription when no longer needed
    super.dispose();
  }

  // Example of sending push notification via FCM API
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
