import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hushhxtinder/ui/app/chat/chatViewModel.dart';
import 'package:hushhxtinder/ui/app/chat/message.dart';
import 'package:hushhxtinder/ui/components/chatBubble.dart';

class ChatScreen extends StatefulWidget {
  final String userTo;
  final String profile;
  final String name;
  final String chatId;

  const ChatScreen({
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
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage; // To hold the selected image file
  double _uploadProgress = 0.0; // To track image upload progress

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _submit(ChatViewModel appService) async {
    final text = _msgController.text;

    if (_selectedImage != null) {
      // Show upload progress while uploading the image
      String? imageUrl = await appService.uploadImageToFirebaseWithProgress(
        _selectedImage!,
        widget.chatId,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (imageUrl != null) {
        await appService.sendMessage(imageUrl, widget.userTo, widget.chatId);
        setState(() {
          _selectedImage = null; // Clear selected image after sending
          _uploadProgress = 0.0; // Reset upload progress
        });
      }
    } else if (text.isNotEmpty) {
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        await appService.sendMessage(text, widget.userTo, widget.chatId);
        _msgController.clear(); // Clear the input field
      }
    }
  }

  // Open image picker to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // A function to determine if a message content is an image URL
  bool isImageUrl(String url) {
    return url.contains('http') && (url.contains('.png') || url.contains('.jpg') || url.contains('.jpeg') || url.contains('.gif'));
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
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.profile),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.name,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
                actions: [
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming soon'),
                        ),
                      );
                    },
                    child: const Icon(Icons.videocam, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming soon'),
                        ),
                      );
                    },
                    child: const Icon(Icons.call, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[messages.length - 1 - index];

                          // Mark the message as read if it's not already marked
                          if (!message.isMine && !message.markAsRead) {
                            appService.markMessageAsRead(message.id);
                          }

                          // Check if the message content is an image URL
                          if (isImageUrl(message.content)) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Align(
                                alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15), // Rounded corners like WhatsApp
                                    border: Border.all(color: Colors.grey.withOpacity(0.5)), // Border for images
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15), // Ensuring image corners are also rounded
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          message.content,
                                          width: 200, // Set max width like WhatsApp
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child; // When loading completes
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: Colors.grey.shade300, // Placeholder color while loading
                                              child: const Center(
                                                child: CircularProgressIndicator(), // Show progress while loading
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: Colors.grey.shade300, // Error placeholder
                                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return ChatBubble(
                              text: message.content,
                              isSender: message.isMine,
                              time: message.createAt.toString(),
                            );
                          }
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              Container(
                decoration: const BoxDecoration(color: Colors.black),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _pickImage, // Open image picker when clicked
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: _selectedImage == null
                              ? TextFormField(
                            controller: _msgController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white24,
                              contentPadding: const EdgeInsets.symmetric(
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
                          )
                              : Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (_uploadProgress > 0 && _uploadProgress < 1)
                                    CircularProgressIndicator(value: _uploadProgress),
                                ],
                              ),
                              TextButton(
                                onPressed: () => _submit(appService),
                                child: const Text('Send Image'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Coming soon'),
                            ),
                          );
                        },
                        child: const Icon(Icons.mic, color: Colors.white),
                      ),
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
