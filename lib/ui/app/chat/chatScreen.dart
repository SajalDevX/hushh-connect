import 'package:flutter/material.dart';
import 'package:hushhxtinder/ui/app/chat/chatViewModel.dart';
import 'package:hushhxtinder/ui/app/chat/message.dart';
import 'package:hushhxtinder/ui/components/chatBubble.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String userTo;
  final String profile;
  final String name;
  final String chatId;

  ChatScreen({
    super.key,
    required this.userTo,
    required this.name,
    required this.profile,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _submit(ChatViewModel appService) async {
    final text = _msgController.text;

    if (text.isEmpty) return;

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await appService.sendMessage(text, widget.userTo, widget.chatId);

      _msgController.clear(); // Clear the input field
    }
  }

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<ChatViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg', // Replace with your image asset path
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),
          // Foreground content
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent, // Transparent background
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.profile),
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.name,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.videocam, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: appService.getMessagesForChat(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final messages = snapshot.data!;

                      return ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[messages.length - 1 - index];

                          // Mark the message as read if it's not already marked
                          if (!message.isMine && !message.markAsRead) {
                            appService.markMessageAsRead(message.id);
                          }

                          return ChatBubble(
                            text: message.content,
                            isSender: message.isMine,
                            time: message.createAt.toString(),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.black),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _msgController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white24,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => _submit(appService),
                                icon: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.mic, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
