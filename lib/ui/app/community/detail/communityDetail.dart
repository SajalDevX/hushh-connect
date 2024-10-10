import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/data/models/card_model.dart';
import 'package:hushhxtinder/data/models/productModel.dart';
import 'package:hushhxtinder/ui/app/community/detail/communityDetailViewModel.dart';
import 'package:hushhxtinder/ui/app/home/currentUserProfile.dart';
import 'package:hushhxtinder/ui/app/home/homeViewmodel.dart';
import 'package:provider/provider.dart';
import 'package:hushhxtinder/ui/components/customCard.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../home/friends_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final int communityId;
  final String communityName;
  const CommunityDetailScreen(
      {Key? key, required this.communityId, required this.communityName})
      : super(key: key);

  @override
  _CommunityDetailScreenState createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final GlobalKey<DraggableCardState> draggableCardKey =
      GlobalKey<DraggableCardState>();
  final ValueNotifier<int> currentCardIndexNotifier = ValueNotifier<int>(0);
  bool _showLoading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show the circular progress indicator for 1 second
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _showLoading = false;
        });
        // Fetch the data after showing the loading indicator
        context
            .read<CommunityUsersViewModel>()
            .fetchUsersAndProductsInCommunity(widget.communityId);
      });
    });

    currentCardIndexNotifier.addListener(() {
      final communityViewModel = context.read<CommunityUsersViewModel>();
      if (currentCardIndexNotifier.value >=
          communityViewModel.usersAndProducts.length - 1) {
        communityViewModel.fetchUsersAndProductsInCommunity(widget.communityId);
      }
    });
  }

  void _refreshScreen() {
    setState(() {
      context
          .read<CommunityUsersViewModel>()
          .fetchUsersAndProductsInCommunity(widget.communityId);
    });
  }

  @override
  void dispose() {
    currentCardIndexNotifier.dispose();
    super.dispose();
  }

  final HomeViewModel viewModel = HomeViewModel();

  void _moveToDetailScreen(List<ImageData> currentCardData) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CurrentUserProfile(
            CardData: currentCardData,
            onMessageClick: () {
              viewModel.addToContact(currentCardData[0].userId);
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

  void _handleLikeOrDislike(bool isLike) {
    final icon = isLike
        ? Image.asset('lib/assets/images/likehushhconnect.png',
            width: 150, height: 150)
        : Image.asset('lib/assets/images/nopehushhconnect.png',
            width: 150, height: 150);

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
    final icon = Image.asset('lib/assets/images/likehushhconnect.png',
        width: 150, height: 150);

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
    return Consumer<CommunityUsersViewModel>(
      builder: (context, viewModel, child) {
        if (_showLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (viewModel.isLoading && viewModel.usersAndProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (viewModel.usersAndProducts.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final cardData = CardData(
          viewModel.usersAndProducts.map((userAndProduct) {
            final user = userAndProduct[
                'users']; // Extract 'users' from 'usersAndProducts'
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

            // Extract products list, handling the case when 'products' might be null
            final List<dynamic> productsJson = userAndProduct['products'] ?? [];
            final List<Product> userProducts = productsJson.map((productJson) {
              return Product.fromJson(
                  productJson); // Assuming Product has a fromJson factory method
            }).toList();

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
        final HomeViewModel _viewModel = HomeViewModel();

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          size: 32,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Define your action for the cancel button (e.g., pop screen)
                          Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        child: Center(
                            child: Text(
                          "Let's be friends",
                          style: GoogleFonts.figtree(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration
                                .none, // This removes the underline
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              bottom: 56,
              child: Center(
                child: DraggableCard(
                  key: draggableCardKey,
                  cardData: cardData,
                  currentCardIndex: currentCardIndexNotifier,
                  imageIndices: imageIndices,
                  viewModel: _viewModel,
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
