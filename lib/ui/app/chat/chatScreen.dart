import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hushhxtinder/ui/app/chat/chatViewModel.dart';
import 'package:hushhxtinder/ui/app/chat/message.dart';
import 'package:hushhxtinder/ui/components/chatBubble.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String userTo;
  final String profile;
  final String name;
  final String chatId;
  final String phone;

  const ChatScreen({
    super.key,
    required this.userTo,
    required this.name,
    required this.profile,
    required this.chatId,
    required this.phone,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  double _uploadProgress = 0.0;
  List<Map<String, dynamic>> _temporaryImages = [];
  String? _fullScreenImage; // To hold the image for fullscreen view

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _submit(ChatViewModel appService) async {
    if (_selectedImage != null) {
      // Add image to chat immediately (optimistic UI)
      setState(() {
        _temporaryImages.add({
          'file': _selectedImage!,
          'progress': 0.0,
        });
        _selectedImage = null;  // Remove overlay immediately
      });

      String? imageUrl = await appService.uploadImageToFirebaseWithProgress(
        _temporaryImages.last['file'],
        widget.chatId,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress; // Update overall progress
            _temporaryImages.last['progress'] = progress;  // Update image-specific progress
          });
        },
      );


      // After upload, send the message to the database
      if (imageUrl != null) {
        await appService.sendMessage(imageUrl, widget.userTo, widget.chatId, true);
        setState(() {
          _uploadProgress = 0.0; // Reset progress
          _temporaryImages.removeLast(); // Remove temporary image after upload
        });
      }
    } else if (_msgController.text.isNotEmpty) {
      final text = _msgController.text;
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        await appService.sendMessage(text, widget.userTo, widget.chatId, false);
        _msgController.clear();
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
    return url.contains('http') &&
        (url.contains('.png') || url.contains('.jpg') || url.contains('.jpeg') || url.contains('.gif'));
  }

  // Display image preview overlay with send and cancel buttons
  Widget _buildImagePreviewOverlay(ChatViewModel appService) {
    return Stack(
      children: [
        // Fullscreen image background
        Positioned.fill(
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover, // Make the image fill the screen
          ),
        ),

        // Cross button in the top-left corner
        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () {
              setState(() {
                _selectedImage = null; // Cancel the image selection
              });
            },
          ),
        ),

        // Send button in the bottom-right corner
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _submit(appService),
            backgroundColor: Colors.green,
            child: const Icon(Icons.send, size: 30),
          ),
        ),
      ],
    );
  }

  // Fullscreen overlay for image preview
  Widget _buildFullScreenImageOverlay() {
    return Stack(
      children: [
        // Black background
        Positioned.fill(
          child: Container(
            color: Colors.black, // Set background color to black
          ),
        ),

        // Fullscreen image
        Positioned.fill(
          child: Image.network(
            _fullScreenImage!,
            fit: BoxFit.contain, // Show full image with aspect ratio preserved
          ),
        ),

        // Close button
        Positioned(
          top: 30,
          left: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () {
              setState(() {
                _fullScreenImage = null; // Close fullscreen
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<ChatViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;  // Get screen width

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
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
                      _makePhoneCall(widget.phone);
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
                        itemCount: messages.length + _temporaryImages.length,
                        itemBuilder: (context, index) {
                          // Show temporary images first
                          if (index < _temporaryImages.length) {
                            final tempImage = _temporaryImages[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Stack(
                                  children: [
                                    // Full-size container
                                    Container(
                                      width: screenWidth * 2 / 3, // Set width to 2/3 of the screen width
                                      height: 250,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.file(
                                          tempImage['file'],
                                          fit: BoxFit.cover, // Full-size image
                                        ),
                                      ),
                                    ),
                                    // Show progress indicator while uploading
                                    if (tempImage['progress'] < 1.0)
                                      Positioned.fill(
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: tempImage['progress'],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Display real messages from the database
                          final message = messages[messages.length - 1 - (index - _temporaryImages.length)];

                          // Mark the message as read if it's not already marked
                          if (!message.isMine && !message.markAsRead) {
                            appService.markMessageAsRead(message.id);
                          }

                          if (isImageUrl(message.content)) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _fullScreenImage = message.content; // Open fullscreen on tap
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Align(
                                  alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    width: screenWidth * 2 / 3, // Set width to 2/3 of the screen width
                                    height: 250, // Full-size container
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            message.content,
                                            fit: BoxFit.cover, // Full-size image
                                            width: screenWidth * 2 / 3, // Set width to 2/3 of the screen width
                                            height: 250,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                width: screenWidth * 2 / 3,
                                                height: 250,
                                                color: Colors.grey.shade300,
                                                child: const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: screenWidth * 2 / 3,
                                                height: 250,
                                                color: Colors.grey.shade300,
                                                child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            DateTime? parsedTime;
                            final lastMessageTimeRaw = message.createAt;
                            parsedTime = DateTime.parse(lastMessageTimeRaw.toString());
                            final String lastMessageTime = DateFormat.jm().format(parsedTime);
                            return ChatBubble(
                              text: message.content,
                              isSender: message.isMine,
                              time: lastMessageTime,
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
                        onPressed: _pickImage,
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
                              : _buildImagePreviewOverlay(appService),
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
          if (_selectedImage != null) _buildImagePreviewOverlay(appService),
          if (_fullScreenImage != null) _buildFullScreenImageOverlay(),
        ],
      ),
    );
  }
}
