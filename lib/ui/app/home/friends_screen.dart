import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/app/chat/chatScreen.dart';
import 'package:hushhxtinder/ui/app/chat/chatViewModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final int shimmerItemCount = 3;

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/app_bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ) +
                const EdgeInsets.only(top: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with SVG icon and icons
                Row(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/images/huash_logo_2.svg',
                      // Replace with your SVG file path
                      height: 30,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming soon'),
                          ),
                        );
                      },
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming soon'),
                          ),
                        );
                      },
                      child:
                          const Icon(Icons.notifications, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // StreamBuilder for real-time data fetching
                Flexible(
                  child: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
                    stream:
                        chatViewModel.fetchSortedUserDetailsWithLastMessage(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: [
                            buildShimmerUserWithoutMessages(),
                            const SizedBox(height: 16),
                            buildShimmerMessageList(),
                          ],
                        );
                      }

                      if (snapshot.hasData) {
                        final usersWithMessages =
                            snapshot.data!['usersWithMessages']!;
                        final usersWithoutMessages =
                            snapshot.data!['usersWithoutMessages']!;

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Horizontal List for users without messages
                              if (usersWithoutMessages.isNotEmpty) ...[
                                Text(
                                  'Super liked People',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 90,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: usersWithoutMessages.length,
                                    itemBuilder: (context, index) {
                                      final contact =
                                          usersWithoutMessages[index];
                                      return buildUserWithoutMessageBox(
                                          context, contact, chatViewModel);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Text(
                                'Messages',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                // Important to use with SingleChildScrollView
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(top: 8),
                                itemCount: usersWithMessages.length,
                                itemBuilder: (context, index) {
                                  final contact = usersWithMessages[index];
                                  final lastMessage = contact['last_message'] !=
                                          null
                                      ? contact['last_message']['message'] ??
                                          'No messages yet'
                                      : 'No messages yet';
                                  final unreadCount = contact['unread_count'];
                                  final lastMessageTimeRaw =
                                      contact['last_message'] != null &&
                                              contact['last_message']
                                                      ['time_sent'] !=
                                                  null
                                          ? contact['last_message']['time_sent']
                                          : DateTime.now().toIso8601String();
                                  final DateTime parsedTime =
                                      DateTime.parse(lastMessageTimeRaw);
                                  final String lastMessageTime =
                                      DateFormat.jm().format(parsedTime);
                                  return buildChatBox(
                                      contact, lastMessage, lastMessageTime,);
                                },
                              ),
                            ],
                          ),
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

                      return Container();
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

  Widget buildUserWithoutMessageBox(BuildContext context,
      Map<String, dynamic> contact, ChatViewModel chatViewModel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
                userTo: contact['contact_userId'] ?? '',
                profile: contact['image'] ?? '',
                name: contact['name'] ?? 'Unknown',
                chatId: contact['chatId'] ?? '',
                phone: contact['phone'] ?? ''),
          ),
        ).then((_) {
          setState(() {
            chatViewModel.fetchSortedUserDetailsWithLastMessage();
          });
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: contact['image'] != null
                  ? NetworkImage(contact['image'])
                  : const AssetImage('lib/assets/images/user_placeholder.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 4),
            Text(
              contact['name'] ?? 'Unknown',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChatBox(Map<String, dynamic> contact, String lastMessage,
      String lastMessageTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
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
                  phone: contact['phone'] ?? ''),
            ),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: contact['image'] != null
                ? NetworkImage(contact['image'])
                : const AssetImage('lib/assets/images/user_placeholder.png')
                    as ImageProvider,
          ),
          title: Text(
            contact['name'] ?? 'Unknown',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            lastMessage,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          trailing: Text(
            lastMessageTime, // Replace with actual time
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
      ),
    );
  }

  /// Build shimmer loading box for horizontal users (without messages)
  Widget buildShimmerUserWithoutMessages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: shimmerItemCount,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build shimmer loading box for vertical message list
  Widget buildShimmerMessageList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shimmerItemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150,
                    height: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
