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

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);

      // Introduce a 1-second delay before fetching data
      await Future.delayed(const Duration(seconds: 1));

      // Fetch contacts and user details
      await viewModel.fetchContacts();
      final userDetails = await viewModel.fetchUserDetails();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            viewModel.userDetails = userDetails;
            isDelayCompleted = true; // Mark delay as complete
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
    final viewModel = Provider.of<HomeViewModel>(context);
    final chatViewModel = Provider.of<ChatViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/app_bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main Content
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
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: isDelayCompleted && !viewModel.isLoading
                        ? viewModel.userDetails.length
                        : shimmerItemCount, // Show a fixed number of shimmers
                    itemBuilder: (context, index) {
                      if (!isDelayCompleted || viewModel.isLoading) {
                        // Show shimmer effect while loading
                        return buildShimmerChatBox();
                      }

                      final contact = viewModel.userDetails[index];

                      // Fetch last message using FutureBuilder
                      return FutureBuilder<Message?>(
                        future: chatViewModel
                            .getLastMessageForChat(contact['chatId']),
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

                            // Display Chatbox with the last message
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Chatbox(
                                image: contact['image'] ?? '',
                                name: contact['name'] ?? 'Unknown',
                                lastMessage: lastMessage,
                                navigateToChatScreen: () {
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
