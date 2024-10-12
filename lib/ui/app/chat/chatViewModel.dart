import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
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
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
  Future<String?> uploadImageToFirebaseWithProgress(
      File imageFile, String chatId, {
        required Function(double) onProgress,
      }) async {
    try {
      final compressedImage = await compressImage(imageFile);
      if (compressedImage == null) return null;

      final String fileName =
          '${chatId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage
          .ref()
          .child('chat_images/$chatId')
          .child(fileName);

      UploadTask uploadTask = ref.putFile(compressedImage);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes != 0) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print("Upload progress: $progress");
          onProgress(progress);
        }
      });

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image to Firebase: $e");
      return null;
    }
  }

  Future<File?> compressImage(File imageFile) async {
    final String newFileName = imageFile.path.split('/').last.replaceAll(RegExp(r'\.(jpg|jpeg|png)'), '.webp');  // Ensure .webp extension
    final String newPath = '${imageFile.absolute.parent.path}/compressed_$newFileName';

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      newPath,  // Use the new path with .webp extension
      quality: 60,  // Adjust the quality as needed
      minWidth: 720,  // Resize image width
      minHeight: 720, // Resize image height (maintain aspect ratio)
      format: CompressFormat.webp,  // Specify the WebP format
    );
    return result;
  }

  Future<void> sendMessage(String content, String userTo, String chatId,bool isImage) async {
    if (currentUserId != null) {
      final message = Message.create(
        content: content,
        userFrom: currentUserId!,
        userTo: userTo,
        chatId: chatId,
      );

      try {
        await _supabase.from('message').insert(message.toMap());


        final lastMessageData = {
          'message': isImage ? 'Photo' : content,
          'time_sent': DateTime.now().toUtc().toIso8601String(),
          'user_from': currentUserId!,
        };

        await _supabase
            .from('contact')
            .update({'last_message': lastMessageData}).eq('chat_id', chatId);

        notifyListeners();
      } catch (e) {
        print("Error sending message or updating contact: $e");
      }
    }
  }

  Stream<Map<String, List<Map<String, dynamic>>>>
  fetchSortedUserDetailsWithLastMessage() {
    final supabaseClient = Supabase.instance.client;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No current user Id found.');
    }

    return supabaseClient
        .from('contact')
        .stream(primaryKey: ['contact_userId'])
        .eq('userId', currentUserId)
        .asyncMap(
          (contacts) async {
        final userIds =
        contacts.map((contact) => contact['contact_userId']).toList();
        final chatIdMap = {
          for (var contact in contacts)
            contact['contact_userId']: contact['chat_id']
        };

        if (userIds.isEmpty) {
          print('No user IDs found in contacts');
          return {
            'usersWithMessages': <Map<String, dynamic>>[],
            'usersWithoutMessages': <Map<String, dynamic>>[]
          };
        }

        // Fetch user details
        final response = await supabaseClient
            .from('users')
            .select('id,name,images,phone')
            .filter('id', 'in', '(${userIds.join(",")})');

        final List<Map<String, dynamic>> usersWithMessages = [];
        final List<Map<String, dynamic>> usersWithoutMessages = [];

        // Iterate through the fetched users asynchronously
        await Future.forEach(response as List<dynamic>, (user) async {
          List<dynamic> imageUrls;
          try {
            imageUrls =
            user['images'] != null ? jsonDecode(user['images']) : [];
          } catch (e) {
            print('Error decoding images JSON: $e');
            imageUrls = [];
          }

          String firstImageUrl = '';
          if (imageUrls.isNotEmpty && imageUrls[0] is String) {
            firstImageUrl = imageUrls[0];
          }

          final chatId = chatIdMap[user['id']];

          // Fetch unread message count for each chat
          final unreadMessageCountResponse = await supabaseClient
              .from('message')
              .select('* head: FetchOptions(count: CountOption.exact)') // Use named count parameter
              .eq('chat_id', chatId)
              .eq('user_to', currentUserId) // Messages sent to the current user
              .eq('mark_as_read', false);

          final unreadMessageCount = unreadMessageCountResponse.length;

          final contact = contacts.firstWhere(
                (contact) => contact['contact_userId'] == user['id'],
            orElse: () => <String, dynamic>{},
          );
          final lastMessage = contact['last_message'] ?? {};
          final lastMessageTime =
              lastMessage['time_sent'] ?? DateTime.now().toIso8601String();

          final userData = {
            'contact_userId': user['id'] as String,
            'name': user['name'] as String,
            'phone': user['phone'] as String,
            'image': firstImageUrl,
            'chatId': chatId ?? '',
            'last_message': lastMessage,
            'last_message_time': lastMessageTime,
            'unread_count': unreadMessageCount, // Unread message count
          };

          if (lastMessage.isEmpty ||
              lastMessage['message'] == null ||
              lastMessage['message'].isEmpty) {
            usersWithoutMessages.add(userData);
          } else {
            usersWithMessages.add(userData);
          }
        });

        // Sort users with messages based on the last message time
        usersWithMessages.sort((a, b) {
          DateTime timeA = DateTime.parse(a['last_message_time']);
          DateTime timeB = DateTime.parse(b['last_message_time']);
          return timeB.compareTo(timeA);
        });

        return {
          'usersWithMessages': usersWithMessages,
          'usersWithoutMessages': usersWithoutMessages,
        };
      },
    );
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
