// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hushhxtinder/data/models/card_model.dart';
import 'package:hushhxtinder/ui/app/home/friendsScreen.dart';
import 'package:hushhxtinder/ui/app/profile/profileScreen.dart';
import 'package:hushhxtinder/ui/components/customCard.dart';
import 'package:provider/provider.dart';
import 'homeViewmodel.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final HomeViewModel _viewModel = HomeViewModel();

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(viewModel: _viewModel),
      const FriendsScreen(),
      const Placeholder(),
      FriendsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>.value(
      value: _viewModel,
      child: MaterialApp(
        home: Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: [
              _buildBottomNavigationBarItem(0, 'home_nav.png'),
              _buildBottomNavigationBarItem(1, 'explore_nav.png'),
              _buildBottomNavigationBarItem(2, 'create_nav.png'),
              _buildBottomNavigationBarItem(3, 'chat_nav.png'),
              _buildBottomNavigationBarItem(4, 'profile_nav.png'),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      int index, String iconPath) {
    return BottomNavigationBarItem(
      icon: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Image.asset(
          'lib/assets/images/$iconPath',
          width: 54,
          height: 54,
          color: _selectedIndex == index ? Colors.purple : Colors.grey,
        ),
      ),
      label: '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  HomeScreen({required this.viewModel});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchUsers();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      widget.viewModel.fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.users.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else if (viewModel.users.isEmpty) {
          return Center(child: Text('No users found.'));
        }

        final cardData = CardData(
          viewModel.users.map<List<ImageData>>((user) {
            final List<dynamic> images = jsonDecode(user["images"] ?? '[]');
            final officeDetails = jsonDecode(user["office_details"] ?? '{}');
            final List<dynamic> passions = jsonDecode(user["passions"] ?? '[]');
            final Map<String, dynamic> socialMediaLinks =
                jsonDecode(user['socialmedia'] ?? '{}');

            // Access the fields using their respective keys
            String instagram = socialMediaLinks['instagram'] ?? 'Not Available';
            String twitter = socialMediaLinks['twitter'] ?? 'Not Available';
            String youtube = socialMediaLinks['youtube'] ?? 'Not Available';
            String linkedin = socialMediaLinks['linkedin'] ?? 'Not Available';
            String otherlink = socialMediaLinks['other'] ?? 'Not Available';

            // Log the values to verify they are being fetched correctly
            // log('Instagram: $instagram');
            // log('Twitter: $twitter');
            // log('YouTube: $youtube');
            // log('LinkedIn: $linkedin');
            // log('Other: $otherlink');

            return [
              ImageData(
                userId: user['id'],
                imageRes: images.isNotEmpty ? images[0] : '', // First image
                name: user['name'] ?? '',
                role: officeDetails['role'] ?? '',
                companyName: officeDetails['company'] ?? '',
                location: user['current_address'],
                description: '',
                contactNumber: user['phone'] ?? '',
                products: [],
                passions: [],
                instagram: '',
                twitter: '',
                linkedin: '',
                youtube: '',
                otherlink: '',
              ),
              ImageData(
                userId: user['id'],
                imageRes: images.length > 1 ? images[1] : '', // Second image
                name: user['name'] ?? '',
                role: officeDetails['role'] ?? '',
                companyName: officeDetails['company'] ?? '',
                location: '',
                description: officeDetails['tasks'] ?? '',
                contactNumber: '',
                products: [],
                passions: [],
                instagram: '',
                twitter: '',
                linkedin: '',
                youtube: '',
                otherlink: '',
              ),
              ImageData(
                userId: user['id'],
                imageRes: images.length > 2 ? images[2] : '', // Third image
                name: user['name'] ?? '',
                role: officeDetails['role'],
                companyName: officeDetails['company'] ?? '',
                location: '',
                description: '',
                contactNumber: '',
                products: [],
                passions: passions,
                instagram: '',
                twitter: '',
                linkedin: '',
                youtube: '',
                otherlink: '',
              ),
              ImageData(
                userId: user['id'],
                imageRes: '', // Fourth card with no image or data
                name: user['name'] ?? '',
                role: '',
                companyName: '',
                location: '',
                description: '',
                contactNumber: '',
                products: [],
                passions: [],
                instagram: '',
                twitter: '',
                linkedin: '',
                youtube: '',
                otherlink: '',
              ),
              ImageData(
                userId: user['id'],
                imageRes: images.length > 2 ? images[2] : '', // Fifth card
                name: user['name'] ?? '',
                role: '',
                companyName: officeDetails['company'] ?? '',
                location: '',
                description: '',
                contactNumber: '',
                products: [],
                passions: [],
                instagram: instagram,
                twitter: twitter,
                linkedin: linkedin,
                youtube: youtube,
                otherlink: otherlink,
              ),
            ];
          }).toList(),
        );

        final imageIndices = ValueNotifier<List<int>>(
            List.generate(cardData.cards.length, (index) => 0));

        return Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'lib/assets/images/app_bg.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            // Custom Top App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset("lib/assets/images/huash_logo_2.svg",
                          fit: BoxFit.contain),
                      Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 16),
                          Image.asset(
                            "lib/assets/images/notify_topbar.png",
                            height: 24,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            // Main Content
            Positioned(
              top:
                  120, // Adjust this value to match the height of the custom app bar
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: DraggableCard(
                  cardData: cardData,
                  currentCardIndex: ValueNotifier<int>(0),
                  imageIndices: imageIndices,
                  viewModel: viewModel,
                  // onCardSwiped: (index) {
                  //   try {
                  //     final currentUserId = cardData.cards[index].first.userId;
                  //     print(currentUserId);
                  //     viewModel.addToContact(currentUserId);
                  //   } catch (e) {
                  //     print('Error adding contact: $e');
                  //   } // Add this user to contact table
                  // },
                ),
              ),
            ),
            // Bottom Navigation Bar Actions
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // Handle reload action
                        },
                        child: Container(
                          height: 47,
                          color: Colors.transparent,
                          child: SvgPicture.asset(
                            'lib/assets/images/reload.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // Handle dislike action
                        },
                        child: Container(
                          height: 67,
                          color: Colors.transparent,
                          child: SvgPicture.asset(
                            'lib/assets/images/dislike.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // Handle boost action
                        },
                        child: Container(
                          height: 47,
                          color: Colors.transparent,
                          child: SvgPicture.asset(
                            'lib/assets/images/star.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // Handle heart action
                        },
                        child: Container(
                          height: 67,
                          color: Colors.transparent,
                          child: SvgPicture.asset(
                            'lib/assets/images/heart.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // Handle spark action
                        },
                        child: Container(
                          height: 47,
                          color: Colors.transparent,
                          child: Image.asset(
                            'lib/assets/images/navbar_fifth.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
