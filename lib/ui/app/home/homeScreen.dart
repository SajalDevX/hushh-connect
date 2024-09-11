// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hushhxtinder/data/models/card_model.dart';
import 'package:hushhxtinder/data/models/productModel.dart';
import 'package:hushhxtinder/ui/app/explore/exploreScreen.dart';
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
      const ExploreScreen(),
      const Placeholder(),
      FriendsScreen(),
      ProfileScreen(),
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
            backgroundColor: const Color(0xff111418),
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
          width: 56,
          height: 56,
          color: _selectedIndex == index ? Colors.purple : Colors.grey,
        ),
      ),
      label: '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  HomeScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<DraggableCardState> draggableCardKey =
      GlobalKey<DraggableCardState>();
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchUsersNearby();
    });
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      widget.viewModel.fetchUsersNearby();
    }
  }

  void _handleLikeOrDislike(bool isLike) {
    final icon = isLike
        ? Image.asset(
            'lib/assets/images/likehushhconnect.png',
            // color: Colors.white,
            width: 150, // Increase the size for better visibility
            height: 150, // Increase the size for better visibility
          )
        : Image.asset(
            'lib/assets/images/nopehushhconnect.png',
            // color: Colors.white,
            width: 150, // Increase the size for better visibility
            height: 150, // Increase the size for better visibility
          );

    // Create an overlay entry
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black, // Adjust opacity to make sure overlay is visible
          child: Center(
            child: icon, // Display the icon
          ),
        ),
      ),
    );

    // Insert the overlay
    Overlay.of(context)?.insert(overlayEntry);

    // After 2 seconds, remove the overlay
    Future.delayed(Duration(milliseconds: 1500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });

    // Handle like or dislike
    if (isLike) {
      draggableCardKey.currentState?.handleLike();
    } else {
      draggableCardKey.currentState?.handleDislike();
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
            final Map<String, dynamic> officeDetails =
                jsonDecode(user["office_details"] ?? '{}');
            final List<dynamic> passions = jsonDecode(user["passions"] ?? '[]');
            final Map<String, dynamic> socialMediaLinks =
                jsonDecode(user['socialmedia'] ?? '{}');

            // Provide default values if any field is null
            final String instagram =
                socialMediaLinks['instagram'] ?? 'Not Available';
            final String twitter =
                socialMediaLinks['twitter'] ?? 'Not Available';
            final String youtube =
                socialMediaLinks['youtube'] ?? 'Not Available';
            final String linkedin =
                socialMediaLinks['linkedin'] ?? 'Not Available';
            final String otherlink =
                socialMediaLinks['other'] ?? 'Not Available';

            final List<Product> userProducts = user['products'] != null
                ? List<Product>.from(user['products'])
                : [];
            log("Products are $userProducts");
            return [
              ImageData(
                userId: user['id'],
                imageRes: images.isNotEmpty ? images[0] : '',
                name: user['name'] ?? '',
                role: officeDetails['role'] ?? '',
                companyName: officeDetails['company'] ?? '',
                location: user['current_address'] ?? '',
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
                imageRes: images.length > 1 ? images[1] : '',
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
                imageRes: images.length > 2 ? images[2] : '',
                name: user['name'] ?? '',
                role: officeDetails['role'] ?? '',
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
                imageRes: '',
                name: user['name'] ?? '',
                role: '',
                companyName: '',
                location: '',
                description: '',
                contactNumber: '',
                products: user['products'] != null
                    ? List<Product>.from(user['products'])
                    : [],
                passions: [],
                instagram: '',
                twitter: '',
                linkedin: '',
                youtube: '',
                otherlink: '',
              ),
              ImageData(
                userId: user['id'],
                imageRes: images.length > 2 ? images[2] : '',
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
            Positioned.fill(
              child: Image.asset(
                'lib/assets/images/app_bg.jpeg',
                fit: BoxFit.cover,
              ),
            ),
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
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: DraggableCard(
                  key: draggableCardKey,
                  cardData: cardData,
                  currentCardIndex: ValueNotifier<int>(0),
                  imageIndices: imageIndices,
                  viewModel: viewModel,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              // _handleLikeOrDislike(false);
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
                              _handleLikeOrDislike(false);
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
                              _handleLikeOrDislike(true);
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
                              _handleLikeOrDislike(true);
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
                        )
                      ],
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
