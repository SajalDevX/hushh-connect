// ignore_for_file: file_names, avoid_print, unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/supabaseCredentials.dart';
import 'package:hushhxtinder/ui/app/chat/message.dart';

class ChatViewModel extends ChangeNotifier {
  final _supabase = SupabaseCredentials.supabaseClient;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Message>> getMessagesForChat(String chatId) {
    return _supabase
        .from('message')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((maps) => maps
            .map((item) => Message.fromJson(item, currentUserId!))
            .toList());
  }

  Future<void> sendMessage(String content, String userTo, String chatId) async {
    if (userTo != null && currentUserId != null) {
      final message = Message.create(
          content: content,
          userFrom: currentUserId!,
          userTo: userTo,
          chatId: chatId);
      try {
        await _supabase.from('message').insert(message.toMap());
        notifyListeners();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _supabase
          .from('message')
          .update({'mark_as_read': true}).eq('id', messageId);
    } catch (e) {
      print("Error marking message as read: $e");
    }
  }
}
