import 'package:flutter/material.dart';

class UserImageCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onCardClick;
  const UserImageCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.onCardClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onCardClick,
        child: Card(
          margin: const EdgeInsets.all(
              0), // Remove additional margins around the card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior:
              Clip.antiAlias, // Ensures the image fits the rounded corners
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // Ensures the image fills the entire space
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://example.com/default_image.png',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              // Overlay the user's name at the bottom
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
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
              )
            ],
          ),
        ));
  }
}
