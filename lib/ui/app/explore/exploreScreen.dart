import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Example list of card data (name and image)
  final List<Map<String, String>> cardData = [
    {
      // 'name': 'Looking for Love',
      'name': '',
      'image': 'lib/assets/images/love.jpeg',
    },
    {
      'name': '',
      // 'name': 'Looking for Job',
      'image': 'lib/assets/images/lookingforjob.jpeg',
    },
    {
      'name': '',
      // 'name': 'Let"s be friends',
      'image': 'lib/assets/images/friends.jpeg',
    },
    {
      'name': '',
      // 'name': 'Coffee date',
      'image': 'lib/assets/images/coffeedate.jpeg',
    },
    {
      'name': '',
      // 'name': 'Gym',
      'image': 'lib/assets/images/gym.jpeg',
    },
    {
      'name': '',
      // 'name': 'Movie Time',
      'image': 'lib/assets/images/movietime.jpeg',
    },
    {
      'name': '',
      // 'name': 'Developers',
      'image': 'lib/assets/images/developers.jpeg',
    },
    {
      'name': '',
      // 'name': 'Superheros',
      'image': 'lib/assets/images/coffeedate.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          // Top Bar with Logo and Icons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          // GridView for 2 columns and 4 rows
          Positioned.fill(
            top: 100, // Adjust as necessary to avoid overlap with top bar
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: cardData.length, // Number of cards to display
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 8.0, // Spacing between columns
                  mainAxisSpacing: 8.0, // Spacing between rows
                  childAspectRatio: 0.75, // Adjust this ratio for card size
                ),
                itemBuilder: (context, index) {
                  final card = cardData[index]; // Get the card data

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                          image: AssetImage(
                              card['image']!), // Card background image
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          card['name']!, // Card name
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
