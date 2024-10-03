import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/app/connect/userdata/userDetailScreen.dart';
import 'package:hushhxtinder/ui/components/userCard.dart';
import 'package:provider/provider.dart';
import 'package:hushhxtinder/ui/app/connect/connectViewModel.dart';
import 'package:shimmer/shimmer.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 0; // Track the current page

  void _onCardClick(String uid) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return UserProfileDetailScreen(
            onMessageClick: () {},
            uid: uid,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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

  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final connectViewModel = Provider.of<ConnectViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "${connectViewModel.followers.length + connectViewModel.followingUsers.length}+ likes",
                    style:
                        GoogleFonts.figtree(fontSize: 19, color: Colors.white),
                  ),
                ),
              ),
              const Divider(color: Colors.grey, thickness: 1.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset(
                      'lib/assets/images/filter.jpeg',
                      height: 20,
                      width: 20,
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentPage = 0; // Set current page
                      });
                      _pageController.jumpToPage(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage == 0
                          ? Colors.white
                          : Colors.grey, // Color for selected page
                    ),
                    child: const Text('Following'),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentPage = 1; // Set current page
                      });
                      _pageController.jumpToPage(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage == 1
                          ? Colors.white
                          : Colors.grey, // Color for selected page
                    ),
                    child: const Text('Followers'),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage == 2
                          ? Colors.white
                          : Colors.grey, // Color for selected page
                    ),
                    child: const Text('Shared'),
                  ),
                ],
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage =
                          index; // Update the current page on page change
                    });
                  },
                  children: [
                    _buildUserSection(
                      users: connectViewModel.followingUsers,
                      isLoading: connectViewModel.isLoadingFollowing,
                    ),
                    _buildUserSection(
                      users: connectViewModel.followers,
                      isFollowing: false,
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
    bool isFollowing = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        isLoading
            ? Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[700]!,
                      highlightColor: Colors.grey[500]!,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[700],
                      ),
                    );
                  },
                ),
              )
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
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index]['users'];
                        final String name = user['name'] ?? 'Unknown User';
                        final String uid = isFollowing
                            ? users[index]['following_id'] ?? 'Unknown Uid'
                            : users[index]['follower_id'] ?? 'Unknown Uid';
                        print("uid is $uid");

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
                          onCardClick: () => _onCardClick(uid),
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
