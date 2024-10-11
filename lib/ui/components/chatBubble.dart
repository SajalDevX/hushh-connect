import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;
  final String time;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isSender,
    required this.time,
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
          child: Row(
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
          ),
        ),
      ),
    );
  }
}
