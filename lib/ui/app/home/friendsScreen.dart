import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/app/chat/chatScreen.dart';
import 'package:hushhxtinder/ui/app/chat/chatViewModel.dart';
import 'package:hushhxtinder/ui/app/chat/message.dart';
import 'package:hushhxtinder/ui/app/home/homeViewmodel.dart';
import 'package:hushhxtinder/ui/onboarding/components/chatBox.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool _isLoading = true; // Combined loading state

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      await viewModel.fetchContacts();

      // Simulate loading time with a delay
      await Future.delayed(const Duration(seconds: 1));

      final userDetails = await viewModel.fetchUserDetails();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          viewModel.userDetails = userDetails;
          _isLoading = false; // Data fetching is complete
        });
      });
    } catch (e) {
      print('Error fetching contacts: $e');
      setState(() {
        _isLoading = false; // Set to false even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final chatViewModel = Provider.of<ChatViewModel>(context);

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 56),
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
                // Show a single main circular progress indicator while loading
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: viewModel.userDetails.length,
                      itemBuilder: (context, index) {
                        final contact = viewModel.userDetails[index];
                        final int unreadCount = contact['unreadCount'] ?? 0;

                        return FutureBuilder<Message?>(
                          future: chatViewModel
                              .getLastMessageForChat(contact['chatId']),
                          builder: (context, snapshot) {
                            // if (snapshot.connectionState ==
                            //     ConnectionState.waiting) {
                            //   return const SizedBox(
                            //     height: 80, // Maintain the item height
                            //     child: Center(
                            //       child: CircularProgressIndicator(),
                            //     ),
                            //   );
                            // } else
                            if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Error loading last message',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            } else if (snapshot.hasData) {
                              final Message? message = snapshot.data;
                              final String lastMessage =
                                  message?.content ?? 'No messages yet';
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Stack(
                                  children: [
                                    Chatbox(
                                      image: contact['image'] ?? '',
                                      name: contact['name'] ?? 'Unknown',
                                      lastMessage: lastMessage,
                                      navigateToChatScreen: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              userTo:
                                                  contact['contact_userId'] ??
                                                      '',
                                              profile: contact['image'] ?? '',
                                              name:
                                                  contact['name'] ?? 'Unknown',
                                              chatId: contact['chatId'] ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        right: 8,
                                        top: 16,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            unreadCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
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
