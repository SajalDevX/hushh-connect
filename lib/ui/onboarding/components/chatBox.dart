import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatbox extends StatefulWidget {
  const Chatbox({
    super.key,
    required this.image,
    required this.lastMessage,
    required this.name,
    required this.navigateToChatScreen,
  });

  final String image;
  final String name;
  final String lastMessage;
  final Function navigateToChatScreen; // Function to navigate to chat screen

  @override
  State<Chatbox> createState() => _ChatboxState();
}

class _ChatboxState extends State<Chatbox> {
  @override
  Widget build(BuildContext context) {
    print('Image URL: ${widget.image}'); // Debug log

    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(80.0),
            child: widget.image.isNotEmpty
                ? Image.network(
                    widget.image,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        width: 52,
                        height: 52,
                        child: Icon(Icons.error, size: 52, color: Colors.red),
                      );
                    },
                  )
                : SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(Icons.person, size: 40),
                  ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget
                    .navigateToChatScreen(); // Call the function to navigate to chat screen
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.name,
                    style: GoogleFonts.redHatText(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.redHatText(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
