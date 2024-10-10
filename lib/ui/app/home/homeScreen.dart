// ignore_for_file: file_names, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hushhxtinder/data/models/card_model.dart';
import 'package:hushhxtinder/data/models/productModel.dart';
import 'package:hushhxtinder/ui/app/connect/connectScreen.dart';
import 'package:hushhxtinder/ui/app/community/exploreScreen.dart';
import 'package:hushhxtinder/ui/app/home/currentUserProfile.dart';
import 'package:hushhxtinder/ui/app/profile/profileScreen.dart';
import 'package:hushhxtinder/ui/app/settings/settingsViewModel.dart';
import 'package:hushhxtinder/ui/app/vibes/vibesScreen.dart';
import 'package:hushhxtinder/ui/components/customCard.dart';
import 'package:provider/provider.dart';
import 'friends_screen.dart';
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
      const ConnectScreen(),
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
          width: 46,
          height: 46,
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
  final GlobalKey<DraggableCardState> draggableCardKey =
      GlobalKey<DraggableCardState>();
  final ValueNotifier<int> currentCardIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Fetch nearby users preference from settings
      final isNearbyUsersOn =
          await context.read<SettingsViewModel>().getNearbyUsersPreference();
      print('Nearby user is : $isNearbyUsersOn');

      // If nearby users preference is true, fetch nearby users
      if (isNearbyUsersOn) {
        await context.read<HomeViewModel>().fetchUsersNearby();
      } else {
        // Else, fetch regular users and products
        await context.read<HomeViewModel>().fetchUsersAndProducts();
      }

      _checkAndOpenVibesScreen();
    });

    // Listen for card index changes to fetch more users when reaching the last card
    currentCardIndexNotifier.addListener(() {
      if (currentCardIndexNotifier.value >= widget.viewModel.users.length - 1) {
        // Check nearby users preference again before fetching
        context
            .read<SettingsViewModel>()
            .getNearbyUsersPreference()
            .then((isNearbyUsersOn) {
          if (isNearbyUsersOn) {
            context.read<HomeViewModel>().fetchUsersNearby();
          } else {
            context.read<HomeViewModel>().fetchUsersAndProducts();
          }
        });
      }
    });
  }

  void _moveToDetailScreen(List<ImageData> currentCardData) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CurrentUserProfile(
            CardData: currentCardData,
            onMessageClick: () {
              widget.viewModel.addToContact(currentCardData[0].userId);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return FriendsScreen();
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
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

  Future<void> _checkAndOpenVibesScreen() async {
    final isVibesActive =
        await widget.viewModel.checkAndOpenVibesScreen(context);
    final vibeEventId = await widget.viewModel.fetchActiveVibeEventId();
    if (isVibesActive) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return VibesScreen(
              vibeEventName: "Bollywood",
              vibeEventId: vibeEventId!,
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
  }

  void _refreshScreen() {
    setState(() {
      widget.viewModel.fetchUsersAndProducts(isReload: true);
    });
  }

  @override
  void dispose() {
    currentCardIndexNotifier.dispose();
    super.dispose();
  }

  void _handleLikeOrDislike(bool isLike) {
    final icon = isLike
        ? Image.asset(
            'lib/assets/images/likehushhconnect.png',
            width: 150,
            height: 150,
          )
        : Image.asset(
            'lib/assets/images/nopehushhconnect.png',
            width: 150,
            height: 150,
          );

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black,
          child: Center(
            child: icon,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });

    if (isLike) {
      draggableCardKey.currentState?.handleLike();
    } else {
      draggableCardKey.currentState?.handleDislike();
    }
  }

  void _handleFollowUser() {
    final icon = Image.asset(
      'lib/assets/images/super_like.png',
      width: 150,
      height: 150,
    );
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black,
          child: Center(
            child: icon,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
    draggableCardKey.currentState?.handleFollow();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (viewModel.users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        final cardData = CardData(
          viewModel.users.map<List<ImageData>>((user) {
            final List<dynamic> images = jsonDecode(user["images"] ?? '[]');
            final Map<String, dynamic> officeDetails =
                jsonDecode(user["office_details"] ?? '{}');
            final List<dynamic> passions = jsonDecode(user["passions"] ?? '[]');
            final Map<String, dynamic> socialMediaLinks =
                jsonDecode(user['socialmedia'] ?? '{}');
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
            // print("IMAGES ARE : ${images.length}");
            final List<Product> userProducts = user['products'] != null
                ? List<Product>.from(user['products'])
                : [];
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
                products: userProducts,
                passions: [],
                instagram: '',
                twitter: '',
                linkedin: '',
                youtube: '',
                otherlink: '',
              ),
              ImageData(
                userId: user['id'],
                imageRes: images.length > 3
                    ? images[3]
                    : (images.length > 2 ? images[2] : ''),
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
                          const SizedBox(width: 16),
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
                  currentCardIndex: currentCardIndexNotifier,
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
                              _refreshScreen();
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
                              _handleFollowUser();
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
                              final currentCardData = cardData
                                  .cards[currentCardIndexNotifier.value];
                              _moveToDetailScreen(currentCardData);
                            },
                            child: Container(
                              height: 36,
                              color: Colors.transparent,
                              child: Image.asset(
                                'lib/assets/images/arrow-up.png',
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
