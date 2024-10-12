import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;
  final String time;
  final bool isImage; // New: To differentiate between text and image messages
  final String? imageUrl; // New: To pass the image URL if it's an image message
  final double? progress; // New: Optional progress for image upload

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isSender,
    required this.time,
    this.isImage = false, // New: Default is false
    this.imageUrl,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isSender ? Colors.green[100] : Colors.white, // Background color for sender or receiver
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomLeft: isSender ? Radius.circular(15) : Radius.zero, // Tail like WhatsApp
              bottomRight: isSender ? Radius.zero : Radius.circular(15),
            ),
          ),
          child: isImage && imageUrl != null
              ? _buildImageMessage() // New: Image message widget
              : _buildTextMessage(), // Text message widget
        ),
      ),
    );
  }

  // Widget for text messages
  Widget _buildTextMessage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end, // Align text and time at the bottom
      mainAxisSize: MainAxisSize.min,
      children: [
        // The message text wrapped with Flexible to avoid overflow
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 5), // Space between text and time
        // Time and checkmark section
        Row(
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4), // Space between time and checkmark
            if (isSender)
              const Icon(
                Icons.check,
                size: 16,
                color: Colors.grey, // Checkmark for sent messages
              ),
          ],
        ),
      ],
    );
  }

  // Widget for image messages
  Widget _buildImageMessage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12), // Rounded corners for the image
          child: Image.network(
            imageUrl!, // The image URL
            width: 200,
            fit: BoxFit.cover, // Adjust the size and fit of the image
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child; // Image loaded successfully
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey.shade300, // Placeholder color
                child: const Center(
                  child: CircularProgressIndicator(), // Loading indicator
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
        ),
        if (progress != null && progress! < 1) // Display progress bar if image is uploading
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: Center(
                child: CircularProgressIndicator(value: progress), // Progress indicator
              ),
            ),
          ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 4),
              if (isSender)
                const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
