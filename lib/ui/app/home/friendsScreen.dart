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
  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
      await viewModel.fetchContacts();

      final userDetails = await viewModel.fetchUserDetails();
      setState(() {
        viewModel.userDetails = userDetails;
      });
    } catch (e) {
      print('Error fetching contacts: $e');
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
                viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 8),
                          itemCount: viewModel.userDetails.length,
                          itemBuilder: (context, index) {
                            final contact = viewModel.userDetails[index];
                            final chatId = contact['chatId'] ?? '';

                            return StreamBuilder<List<Message>>(
                              stream: chatViewModel.getMessagesForChat(
                                  chatId), // Assume this method returns a Stream<List<Message>>
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(
                                      child: Text('Error loading messages'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Chatbox(
                                      image: contact['image'] ?? '',
                                      name: contact['name'] ?? 'Unknown',
                                      lastMessage: 'No messages',
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
                                              chatId: chatId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  final messages = snapshot.data!;
                                  final lastMessage = messages.isNotEmpty
                                      ? messages.last.toString()
                                      : '';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Chatbox(
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
                                              chatId: chatId,
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
