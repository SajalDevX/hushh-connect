import 'package:flutter/material.dart';

class UserImageCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const UserImageCard({
    Key? key,
    required this.name,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior:
          Clip.antiAlias, // Ensures the image fits the rounded corners
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Display the image
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.network(
                'https://example.com/default_image.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              );
            },
          ),
          // Overlay the user's name at the bottom
          Container(
            width: double.infinity,
            color: Colors.black.withOpacity(0.5),
            padding: const EdgeInsets.all(10),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
