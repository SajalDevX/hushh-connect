import 'package:flutter/material.dart';

class Explorecard extends StatefulWidget {
  final String data;
  final String imageUrl;
  const Explorecard({super.key, required this.data, required this.imageUrl});

  @override
  State<Explorecard> createState() => _ExplorecardState();
}

class _ExplorecardState extends State<Explorecard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 254,
      width: double.infinity,
      child: Stack(
        children: [
          // Image positioned as background, filling the container
          Positioned.fill(
            child: Image.asset(
              widget.imageUrl,
              fit:
                  BoxFit.cover, // Ensures the image covers the entire container
            ),
          ),
          Center(
            child: Text(
              widget.data,
              style: const TextStyle(
                color: Colors.white, // Ensures the text is visible on the image
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0.0, 0.0),
                    blurRadius: 4.0,
                    color: Colors.white, // Adds a shadow for better readability
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
