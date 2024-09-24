import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hushhxtinder/ui/app/home/currentUserProfile.dart';
import 'package:hushhxtinder/ui/components/userCard.dart';
import 'package:provider/provider.dart';
import 'package:hushhxtinder/ui/app/connect/connectViewModel.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // void _onCardClick() {
  //   Navigator.push(
  //     context,
  //     PageRouteBuilder(
  //       pageBuilder: (context, animation, secondaryAnimation) {
  //         return CurrentUserProfile(
  //           CardData: currentCardData,
  //           onMessageClick: () {},
  //         );
  //       },
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //         const begin = Offset(0.0, 1.0);
  //         const end = Offset.zero;
  //         const curve = Curves.ease;

  //         var tween =
  //             Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //         var offsetAnimation = animation.drive(tween);

  //         return SlideTransition(
  //           position: offsetAnimation,
  //           child: child,
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Use addPostFrameCallback to ensure data fetching is done after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectViewModel =
          Provider.of<ConnectViewModel>(context, listen: false);

      connectViewModel.fetchFollowingUsers();
      connectViewModel.fetchFollowers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectViewModel = Provider.of<ConnectViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        "lib/assets/images/huash_logo_2.svg",
                        height: 28,
                        width: 28,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              // TabBar for User List Sections
              Container(
                color: Colors.transparent,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.amber,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    // Tab(text: 'Mutual'),
                    Tab(text: 'Following'),
                    Tab(text: 'Followers'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // _buildUserSection(
                    //   users: connectViewModel.mutualUsers,
                    //   isLoading: connectViewModel.isLoadingMutual,
                    // ),
                    _buildUserSection(
                      users: connectViewModel.followingUsers,
                      isLoading: connectViewModel.isLoadingFollowing,
                    ),
                    _buildUserSection(
                      users: connectViewModel.followers,
                      isLoading: connectViewModel.isLoadingFollowers,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection({
    required List<Map<String, dynamic>> users,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
                ? const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns
                        crossAxisSpacing: 10.0, // Space between columns
                        mainAxisSpacing: 10.0, // Space between rows
                        childAspectRatio:
                            0.75, // Adjust the aspect ratio if needed
                      ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index]['users'];

                        final String name = user['name'] ?? 'Unknown User';

                        final String imagesJson = user['images'] ?? '[]';
                        List<dynamic> images = [];
                        try {
                          images = jsonDecode(imagesJson) as List<dynamic>;
                        } catch (e) {
                          print('Error decoding images JSON: $e');
                        }

                        String imageUrl = images.isNotEmpty
                            ? images[0] as String
                            : 'https://fallback.url/default.jpg';

                        return UserImageCard(
                          onCardClick: () {},
                          name: name,
                          imageUrl: imageUrl,
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
