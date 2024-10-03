import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/app/chat/chatScreen.dart';
import 'package:hushhxtinder/ui/app/chat/chatViewModel.dart';
import 'package:hushhxtinder/ui/app/chat/message.dart';
import 'package:hushhxtinder/ui/app/home/homeViewmodel.dart';
import 'package:hushhxtinder/ui/components/chatBox.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool isDelayCompleted = false; // Track the delay state
  final int shimmerItemCount =
      3; // Set the fixed number of shimmer placeholders

  List<Map<String, dynamic>> emptyLastMessageContacts =
      []; // To hold contacts with empty messages

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
      await Future.delayed(const Duration(seconds: 1));
      await chatViewModel.fetchContacts();
      final userDetails = await chatViewModel.fetchUserDetails();

      // Use a List to keep track of futures for each contact's last message
      final lastMessageFutures = <Future<void>>[];

      for (var contact in userDetails) {
        final lastMessageFuture = chatViewModel
            .getLastMessageForChat(contact['chatId'])
            .first
            .then((lastMessage) {
          contact['lastMessage'] =
              lastMessage?.content ?? ''; // Store message content
          contact['lastMessageTime'] = lastMessage?.createAt ?? DateTime.now();

          // Check if the last message is empty and add to the empty list
          if (contact['lastMessage'].isEmpty) {
            emptyLastMessageContacts.add(contact);
          }
        });

        lastMessageFutures.add(lastMessageFuture);
      }

      // Wait for all futures to complete
      await Future.wait(lastMessageFutures);

      // Sort userDetails based on last message time
      userDetails.sort((a, b) => (b['lastMessageTime'] as DateTime)
          .compareTo(a['lastMessageTime'] as DateTime));

      // Update state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            chatViewModel.userDetails = userDetails;
            isDelayCompleted = true;
          });
        }
      });
    } catch (e) {
      print('Error fetching contacts: $e');
    }
  }

  Widget buildShimmerText(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ChatViewModel>(context);

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

                // Horizontal ListView for users with empty last messages
                if (isDelayCompleted)
                  SizedBox(
                    height: 69, // Set the fixed height for the row
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: emptyLastMessageContacts.length,
                      itemBuilder: (context, index) {
                        final contact = emptyLastMessageContacts[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
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
                            child: Column(
                              mainAxisSize: MainAxisSize
                                  .min, // Add this to avoid Column stretching to full height
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(contact['image'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                const SizedBox(
                                    height: 4), // Adjust spacing if needed
                                FittedBox(
                                  // This ensures text doesn't overflow
                                  child: Text(
                                    contact['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),
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
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: isDelayCompleted && !viewModel.isLoading
                        ? viewModel.userDetails
                            .where((contact) => contact['lastMessage'] != '')
                            .length
                        : shimmerItemCount,
                    itemBuilder: (context, index) {
                      if (!isDelayCompleted || viewModel.isLoading) {
                        return buildShimmerChatBox();
                      }

                      // Filter out contacts with no last message
                      final contact = viewModel.userDetails
                          .where((contact) => contact['lastMessage'] != '')
                          .toList()[index];

                      return StreamBuilder<Message?>(
                        stream:
                            viewModel.getLastMessageForChat(contact['chatId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return buildShimmerChatBox();
                          } else if (snapshot.hasError) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Error loading last message',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          } else {
                            final lastMessage =
                                snapshot.data?.content ?? 'No messages yet';

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
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
                                  if (result == true) {
                                    _fetchContacts();
                                  }
                                  print("Result from ChatScreen: $result");
                                },
                              ),
                            );
                          }
                        },
                      );
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
}
