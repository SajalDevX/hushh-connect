// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/data/models/card_model.dart';
import 'package:hushhxtinder/ui/app/home/homeViewmodel.dart';
import 'package:hushhxtinder/ui/components/blockProgressbar.dart';
import 'package:hushhxtinder/ui/components/productCard.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class DraggableCard extends StatefulWidget {
  final CardData cardData;
  final ValueNotifier<int> currentCardIndex;
  final ValueNotifier<List<int>> imageIndices;
  final HomeViewModel viewModel;

  DraggableCard({
    Key? key,
    required this.cardData,
    required this.currentCardIndex,
    required this.imageIndices,
    required this.viewModel,
  }) : super(key: key);

  @override
  DraggableCardState createState() => DraggableCardState();
}

class DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetXAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _alphaAnimation;

  double offsetX = 0;
  double rotation = 0;
  double alpha = 1;
  late double screenWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _offsetXAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _alphaAnimation = Tween<double>(begin: 1, end: 1).animate(_controller);

    _controller.addListener(() {
      setState(() {
        offsetX = _offsetXAnimation.value;
        rotation = _rotationAnimation.value;
        alpha = _alphaAnimation.value;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragEnd(DragEndDetails details) {
    final bool isSwipeRight =
        offsetX > screenWidth * 0.4; // Changed from 0.3 to 0.5
    final bool isSwipeLeft =
        offsetX < -screenWidth * 0.4; // Negative value for left swipe

    if (isSwipeRight || _controller.isAnimating || isSwipeLeft) {
      // Ensure the last card is processed
      if (widget.currentCardIndex.value <= widget.cardData.cards.length - 1) {
        // Check if it's the last card or not
        final isLastCard =
            widget.currentCardIndex.value == widget.cardData.cards.length - 1;

        // Call the onCardSwiped function for right swipe
        final index = widget.currentCardIndex.value;
        final currentUserId = widget.cardData.cards[index].first.userId;

        if (isSwipeRight) {
          widget.viewModel.addToContact(currentUserId);

          widget.currentCardIndex.value++;
          widget.imageIndices.value[widget.currentCardIndex.value] = 0;
        }

        // Move to the next card if it's not the last card
        if (!isLastCard) {
          widget.currentCardIndex.value++;
          widget.imageIndices.value[widget.currentCardIndex.value] = 0;
        } else {
          // Show empty screen or handle last card swipe
          widget.currentCardIndex.value = -1;
          widget.imageIndices.value = [];
        }

        _controller.forward(from: 0).whenComplete(() {
          setState(() {
            offsetX = 0;
            rotation = 0;
            alpha = 1;
          });
        });
      }
    } else {
      // Return to original position
      _controller.reverse(from: 0).whenComplete(() {
        setState(() {
          offsetX = 0;
          rotation = 0;
          alpha = 1;
        });
      });
    }
  }

  void handleLike() {
    final index = widget.currentCardIndex.value;
    final currentUserId = widget.cardData.cards[index].first.userId;

    widget.viewModel.addToContact(currentUserId);
    _controller.forward(from: 0).whenComplete(() {
      _moveToNextCard();
    });
  }

  void handleFollow() {
    final index = widget.currentCardIndex.value;
    final currentUserId = widget.cardData.cards[index].first.userId;

    widget.viewModel.followUser(currentUserId);
    _controller.forward(from: 0).whenComplete(() {
      _moveToNextCard();
    });
  }

  void handleDislike() {
    _controller.forward(from: 0).whenComplete(() {
      _moveToNextCard();
    });
  }

  void _moveToNextCard() {
    setState(() {
      final isLastCard =
          widget.currentCardIndex.value == widget.cardData.cards.length - 1;

      if (!isLastCard) {
        widget.currentCardIndex.value++;
        widget.imageIndices.value[widget.currentCardIndex.value] = 0;
      } else {
        widget.currentCardIndex.value = -1; // No more cards
        widget.imageIndices.value = [];
      }

      // Reset animations
      _resetAnimations();
    });
  }

  void _resetAnimations() {
    // Reset the animations for next card
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _offsetXAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _alphaAnimation = Tween<double>(begin: 1, end: 1).animate(_controller);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      offsetX += details.delta.dx;
      rotation = (offsetX / screenWidth) * 30;
      alpha = 1 - (offsetX.abs() / screenWidth);
    });
  }

  void _nextImage() {
    setState(() {
      int currentCard = widget.currentCardIndex.value;
      int currentImage = widget.imageIndices.value[currentCard];
      if (currentImage < widget.cardData.cards[currentCard].length - 1) {
        widget.imageIndices.value[currentCard]++;
      }
    });
  }

  void _previousImage() {
    setState(() {
      int currentCard = widget.currentCardIndex.value;
      int currentImage = widget.imageIndices.value[currentCard];
      if (currentImage > 0) {
        widget.imageIndices.value[currentCard]--;
      } else if (currentCard > 0) {
        widget.currentCardIndex.value--;
        widget.imageIndices.value[widget.currentCardIndex.value] =
            widget.cardData.cards[widget.currentCardIndex.value].length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCardIndex = widget.currentCardIndex.value;
    if (currentCardIndex < 0 ||
        currentCardIndex >= widget.cardData.cards.length) {
      return Container(
        color: Colors.transparent,
        child: Center(
          child: Text(
            'No more cards',
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
      );
    }

    final currentImageIndex = widget.imageIndices.value[currentCardIndex];
    final imageData =
        widget.cardData.cards[currentCardIndex][currentImageIndex];

    final totalImages = widget.cardData.cards[currentCardIndex].length;
    final progress = totalImages > 0
        ? (currentImageIndex + 1) / totalImages.toDouble()
        : 0.0;

    Widget cardContent;

    final likeOpacity =
        offsetX > 0 ? (offsetX / screenWidth).clamp(0.0, 1.0) : 0.0;
    final dislikeOpacity =
        offsetX < 0 ? (offsetX.abs() / screenWidth).clamp(0.0, 1.0) : 0.0;

    switch (currentImageIndex % 5) {
      // Corrected to % 5
      case 0:
        cardContent = _buildProfileCard(
            imageData, likeOpacity, dislikeOpacity, totalImages, progress);
        break;
      case 1:
        cardContent = _buildDetailedProfileCard(
            imageData, likeOpacity, dislikeOpacity, totalImages, progress);
        break;
      case 2:
        cardContent = _buildPassionsCard(
            imageData, likeOpacity, dislikeOpacity, totalImages, progress);
        break;
      case 3:
        cardContent = _buildProductCard(
            imageData, likeOpacity, dislikeOpacity, totalImages, progress);
        break;
      case 4:
        cardContent = _buildSocialCard(
            imageData, likeOpacity, dislikeOpacity, totalImages, progress);
        break;
      default:
        cardContent = _buildSocialCard(
            imageData, likeOpacity, dislikeOpacity, totalImages, progress);
    }
    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: _onDragUpdate,
          onPanEnd: _onDragEnd,
          onTapUp: (details) {
            final tapPosition = details.localPosition.dx;
            if (tapPosition < screenWidth / 2) {
              // Tap on the left half of the screen
              _previousImage();
            } else {
              // Tap on the right half of the screen
              _nextImage();
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(offsetX, 0),
                  child: Transform.rotate(
                    angle: rotation * (math.pi / 180),
                    child: Opacity(
                      opacity: alpha,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.black.withOpacity(1)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: cardContent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(ImageData imageData, double likeOpacity,
      double dislikeOpacity, int totalImages, double progress) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.network(
                imageData.imageRes,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Icon(Icons.error, color: Colors.red));
                },
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.4,
                    1.0
                  ], // Gradient effect covers bottom 60% of the image
                ),
              ),
            ),
          ),
          // "Like" icon
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: likeOpacity,
              child: Transform.rotate(
                angle: -math.pi / 12, // Tilt the "Like" icon
                child: Image.asset(
                  "lib/assets/images/likehushhconnect.png",
                  height: 148,
                  width: 148,
                ),
              ),
            ),
          ),
          // "Dislike" icon
          Positioned(
            top: 40,
            right: 20,
            child: Opacity(
              opacity: dislikeOpacity,
              child: Transform.rotate(
                angle: math.pi / 12, // Tilt the "Dislike" icon
                child: Image.asset(
                  "lib/assets/images/nopehushhconnect.png",
                  height: 148,
                  width: 148,
                ),
              ),
            ),
          ),
          // Progress bar
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: BlockProgressBar(
              totalBlocks: totalImages,
              progress: progress,
              height: 6.0,
            ),
          ),
          // Content
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Row(
                    children: [
                      Text(
                        imageData.name,
                        style: GoogleFonts.figtree(
                          fontSize: 32.69231,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.09615,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 19,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Role and company name
                  Text(
                    '${imageData.role} @ ${imageData.companyName}',
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 0.09615,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Location
                  Text(
                    imageData.location,
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 0.09615,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Read more link
                  GestureDetector(
                    onTap:
                        _goToDetailedProfile, // Updated to navigate to detailed profile
                    child: Text(
                      'Read more',
                      style: GoogleFonts.figtree(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        letterSpacing: 0.09615,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedProfileCard(ImageData imageData, double likeOpacity,
      double dislikeOpacity, int totalImages, double progress) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.network(
                imageData.imageRes,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Icon(Icons.error, color: Colors.red));
                },
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.4,
                    1.0
                  ], // Gradient effect covers bottom 60% of the image
                ),
              ),
            ),
          ),
          // "Like" icon
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: likeOpacity,
              child: Transform.rotate(
                angle: -math.pi / 12, // Tilt the "Like" icon
                child: Image.asset(
                  "lib/assets/images/likehushhconnect.png",
                  height: 148,
                  width: 148,
                ),
              ),
            ),
          ),
          // "Dislike" icon
          Positioned(
            top: 40,
            right: 20,
            child: Opacity(
              opacity: dislikeOpacity,
              child: Transform.rotate(
                angle: math.pi / 12, // Tilt the "Dislike" icon
                child: Image.asset(
                  "lib/assets/images/nopehushhconnect.png",
                  height: 148,
                  width: 148,
                ),
              ),
            ),
          ),
          // Progress Bar
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: BlockProgressBar(
              totalBlocks: totalImages,
              progress: progress,
              height: 6.0,
            ),
          ),
          // Content
          Positioned(
            bottom: 90, // Adjusted to provide more margin from bottom icons
            left: 20, // Adjusted for consistent margin
            right: 20, // Adjusted for consistent margin
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 0.0), // Set to 0 for consistent edge
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        imageData.name,
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.09615,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 19,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${imageData.role} @ ${imageData.companyName}',
                    style: GoogleFonts.figtree(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.09615,
                    ),
                  ),
                  SizedBox(
                      height: 12), // Increased spacing for better readability
                  Text(
                    imageData
                        .description, // Dynamically load description from imageData
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 0.09615,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildProductCard(ImageData imageData, double likeOpacity,
  //     double dislikeOpacity, int totalImages, double progress) {
  //   return Card(
  //     color: Colors.grey.withOpacity(0.5),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     clipBehavior: Clip.antiAlias,
  //     child: Stack(
  //       fit: StackFit.expand,
  //       children: [
  //         Positioned.fill(
  //           child: Opacity(
  //             opacity: 1,
  //             child: Image.network(
  //               imageData.imageRes,
  //               fit: BoxFit.cover,
  //               loadingBuilder: (BuildContext context, Widget child,
  //                   ImageChunkEvent? loadingProgress) {
  //                 if (loadingProgress == null) {
  //                   return child;
  //                 }
  //                 return Center(
  //                   child: CircularProgressIndicator(
  //                     value: loadingProgress.expectedTotalBytes != null
  //                         ? loadingProgress.cumulativeBytesLoaded /
  //                             (loadingProgress.expectedTotalBytes ?? 1)
  //                         : null,
  //                   ),
  //                 );
  //               },
  //               errorBuilder: (context, error, stackTrace) {
  //                 return Positioned.fill(
  //                   child: Container(
  //                     color:
  //                         Colors.transparent, // Make the container transparent
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ),
  //         Positioned.fill(
  //           child: Container(
  //             decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                     colors: [Colors.white.withOpacity(0.1), Colors.black],
  //                     begin: Alignment.topCenter,
  //                     end: Alignment.bottomCenter)),
  //           ),
  //         ),
  //         Positioned(
  //           top: 40,
  //           left: 20,
  //           child: Opacity(
  //             opacity: likeOpacity,
  //             child: Transform.rotate(
  //               angle: -math.pi / 12, // Tilt the "Like" icon
  //               child: Image.asset(
  //                 "lib/assets/images/likehushhconnect.png",
  //                 height: 148,
  //                 width: 148,
  //               ),
  //             ),
  //           ),
  //         ),
  //         // "Dislike" icon
  //         Positioned(
  //           top: 40,
  //           right: 20,
  //           child: Opacity(
  //             opacity: dislikeOpacity,
  //             child: Transform.rotate(
  //               angle: math.pi / 12, // Tilt the "Dislike" icon
  //               child: Image.asset(
  //                 "lib/assets/images/nopehushhconnect.png",
  //                 height: 148,
  //                 width: 148,
  //               ),
  //             ),
  //           ),
  //         ),
  //         // Progress Bar
  //         Positioned(
  //           top: 10,
  //           left: 10,
  //           right: 10,
  //           child: BlockProgressBar(
  //             totalBlocks: totalImages,
  //             progress: progress,
  //             height: 6.0,
  //           ),
  //         ),
  //         // Content
  //         Positioned(
  //           bottom: 64,
  //           left: 0,
  //           right: 0,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 25.0),
  //             child: Container(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Text(
  //                         imageData.name,
  //                         textAlign: TextAlign.justify,
  //                         style: TextStyle(
  //                           fontSize: 32,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white,
  //                         ),
  //                       ),
  //                       SizedBox(width: 5),
  //                       Icon(
  //                         Icons.verified,
  //                         color: Colors.blue,
  //                         size: 19,
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildProductCard(ImageData imageData, double likeOpacity,
      double dislikeOpacity, int totalImages, double progress) {
    // Calculate the number of products to display (maximum 4)
    int productsToShow =
        imageData.products.length > 4 ? 4 : imageData.products.length;

    // Create a list of ProductCard widgets
    List<Widget> productCards = List.generate(productsToShow, (index) {
      final product =
          imageData.products[index]; // Assuming imageData has a 'products' list

      return ProductCard(
          product:
              product); // Use the ProductCard widget to display each product
    });

    return Card(
      color: Colors.grey.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'lib/assets/images/app_bg.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Positioned.fill(
                    child: Container(
                      color: Colors.transparent,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: likeOpacity,
              child: Transform.rotate(
                angle: -math.pi / 12,
                child: Image.asset(
                  "lib/assets/images/likehushhconnect.png",
                  height: 148,
                  width: 148,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Opacity(
              opacity: dislikeOpacity,
              child: Transform.rotate(
                angle: math.pi / 12,
                child: Image.asset(
                  "lib/assets/images/nopehushhconnect.png",
                  height: 148,
                  width: 148,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: BlockProgressBar(
              totalBlocks: totalImages,
              progress: progress,
              height: 6.0,
            ),
          ),
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        imageData.name,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 19,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Products",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Constrain the height of the GridView to prevent overflow
                  SizedBox(
                    height: 800, // Adjust the height as needed
                    child: GridView.count(
                      crossAxisCount: 2, // Two products per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Disable scrolling inside the grid
                      children: productCards,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassionsCard(ImageData imageData, double likeOpacity,
      double dislikeOpacity, int totalImages, double progress) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.network(
                imageData.imageRes,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Icon(Icons.error, color: Colors.red));
                },
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.4,
                    1.0
                  ], // Gradient effect covers bottom 60% of the image
                ),
              ),
            ),
          ),
          // "Like" icon
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: likeOpacity,
              child: Transform.rotate(
                angle: -math.pi / 12, // Tilt the "Like" icon
                child: Image.asset(
                  "lib/assets/images/likehushhconnect.png",
                  height: 148,
                  width: 148,
                ),
              ),
            ),
          ),
          // "Dislike" icon
          Positioned(
            top: 40,
            right: 20,
            child: Opacity(
              opacity: dislikeOpacity,
              child: Transform.rotate(
                angle: math.pi / 12, // Tilt the "Dislike" icon
                child: Image.asset(
                  "lib/assets/images/nopehushhconnect.png",
                  height: 148,
                  width: 148,
                ),
              ),
            ),
          ),
          // Progress Bar
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: BlockProgressBar(
              totalBlocks: totalImages,
              progress: progress,
              height: 6.0,
            ),
          ),
          // Content
          Positioned(
            bottom: 90, // Increased to provide more margin from bottom icons
            left: 20, // Consistent margin
            right: 20, // Consistent margin
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        imageData.name,
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.09615,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 19,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${imageData.role} @ ${imageData.companyName}',
                    style: GoogleFonts.figtree(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.09615,
                    ),
                  ),
                  SizedBox(
                      height: 12), // Increased spacing for better readability
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: imageData.passions.map((passion) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                          color: Colors.transparent, // Transparent background
                        ),
                        child: Text(
                          passion,
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.white, // White text color
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildSocialCard(ImageData imageData, double likeOpacity,
      double dislikeOpacity, int totalImages, double progress) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.network(
                imageData.imageRes,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Icon(Icons.error, color: Colors.red));
                },
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.4,
                    1.0
                  ], // Gradient effect covers bottom 60% of the image
                ),
              ),
            ),
          ),
          // "Like" icon
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: likeOpacity,
              child: Transform.rotate(
                angle: -math.pi / 12, // Tilt the "Like" icon
                child: GestureDetector(
                  onTap: () => _launchURL('https://www.example.com/like'),
                  child: Image.asset(
                    "lib/assets/images/likehushhconnect.png",
                    height: 148,
                    width: 148,
                  ),
                ),
              ),
            ),
          ),
          // "Dislike" icon
          Positioned(
            top: 40,
            right: 20,
            child: Opacity(
              opacity: dislikeOpacity,
              child: Transform.rotate(
                angle: math.pi / 12, // Tilt the "Dislike" icon
                child: GestureDetector(
                  onTap: () => _launchURL('https://www.example.com/dislike'),
                  child: Image.asset(
                    "lib/assets/images/nopehushhconnect.png",
                    height: 148,
                    width: 148,
                  ),
                ),
              ),
            ),
          ),
          // Progress Bar
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: BlockProgressBar(
              totalBlocks: totalImages,
              progress: progress,
              height: 6.0,
            ),
          ),
          // Content
          Positioned(
            bottom: 90, // Adjusted for more margin from bottom icons
            left: 20, // Consistent margin
            right: 20, // Consistent margin
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 0.0), // Set to 0 for consistent edge
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Connect with",
                    style: GoogleFonts.pacifico(
                      fontWeight: FontWeight.w400,
                      fontSize:
                          27, // Fixed font size for consistency with design
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: <Color>[
                          Color(0xffe54d60),
                          Color(0xffa342ff),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${imageData.name}!",
                        style: GoogleFonts.pacifico(
                          fontWeight: FontWeight.w400,
                          fontSize: 44, // Use fixed size for better control
                          color: Colors.white, // Default color
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 16), // Adjusted for better spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _launchURL(
                            'https://www.linkedin.com/${imageData.linkedin}'),
                        child: SvgPicture.asset(
                            'lib/assets/images/linkedin_svg.svg'),
                      ),
                      GestureDetector(
                        onTap: () => _launchURL(
                            'https://www.youtube.com/${imageData.youtube}'),
                        child: SvgPicture.asset(
                            'lib/assets/images/youtube_svg.svg'),
                      ),
                      GestureDetector(
                        onTap: () => _launchURL(
                            'https://www.facebook.com/${imageData.otherlink}'),
                        child: SvgPicture.asset(
                            'lib/assets/images/facebook_svg.svg'),
                      ),
                      GestureDetector(
                        onTap: () => _launchURL(
                            'https://www.twitter.com/${imageData.twitter}'),
                        child: SvgPicture.asset(
                            'lib/assets/images/twitter_svg.svg'),
                      ),
                      GestureDetector(
                        onTap: () => _launchURL(
                            'https://www.instagram.com/${imageData.instagram}'),
                        child: SvgPicture.asset(
                            'lib/assets/images/instagram_svg.svg'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16), // Adjusted for consistent spacing
                  Text(
                    "www.${imageData.otherlink}.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "www.${imageData.name}.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToDetailedProfile() {
    setState(() {
      int currentCard = widget.currentCardIndex.value;
      int currentImage = widget.imageIndices.value[currentCard];
      if (currentImage == 0) {
        print('Navigating to detailed profile card');
        widget.imageIndices.value[currentCard] = 1; // Navigate to Card 2
      }
    });
  }
}
