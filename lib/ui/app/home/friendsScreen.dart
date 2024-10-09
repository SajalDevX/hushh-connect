import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/app/chat/chatScreen.dart';
import 'package:hushhxtinder/ui/app/chat/chatViewModel.dart';
import 'package:hushhxtinder/ui/components/chatBox.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}


class _FriendsScreenState extends State<FriendsScreen> {
  bool isDelayCompleted = false;
  final int shimmerItemCount = 3; // Number of shimmer items while loading

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/app_bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/images/huash_logo_2.svg',
                      height: 28,
                    ),
                    const Spacer(),
                    const Icon(Icons.search, color: Colors.white),
                    const SizedBox(width: 16),
                    const Icon(Icons.notifications, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 36),

                Text(
                  'Messages',
                  style: GoogleFonts.redHatText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),

                Expanded(
                  // Use StreamBuilder to listen for real-time user and message updates
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: chatViewModel.fetchSortedUserDetailsWithLastMessage(),
                    builder: (context, snapshot) {
                      // If the stream is still loading, show shimmer loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: shimmerItemCount,
                          itemBuilder: (context, index) => buildShimmerChatBox(),
                        );
                      }

                      // If we have data, display the user list
                      if (snapshot.hasData) {
                        final userDetails = snapshot.data!;

                        if (userDetails.isEmpty) {
                          return const Center(
                            child: Text(
                              'No contacts found.',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: userDetails.length,
                          itemBuilder: (context, index) {
                            final contact = userDetails[index];
                            final lastMessage = contact['last_message'] != null
                                ? contact['last_message']['message'] ?? 'No messages yet'
                                : 'No messages yet';

                            return buildChatBox(contact, lastMessage);
                          },
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Error loading contacts',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      return Container(); // Return empty container for other states
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Function to build individual chat boxes
  Widget buildChatBox(Map<String, dynamic> contact, String lastMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userTo: contact['contact_userId'] ?? '',
                profile: contact['image'] ?? '',
                name: contact['name'] ?? 'Unknown',
                chatId: contact['chatId'] ?? '',
              ),
            ),
          );
        },
        child: Chatbox(
          image: contact['image'] ?? '',
          name: contact['name'] ?? 'Unknown',
          lastMessage: lastMessage,
          navigateToChatScreen: () async {
            final result = Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  userTo: contact['contact_userId'] ?? '',
                  profile: contact['image'] ?? '',
                  name: contact['name'] ?? 'Unknown',
                  chatId: contact['chatId'] ?? '',
                ),
              ),
            );
            print("Result from ChatScreen: $result");
          },
        ),
      ),
    );
  }

  /// Function to build shimmer loading box
  Widget buildShimmerChatBox() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
