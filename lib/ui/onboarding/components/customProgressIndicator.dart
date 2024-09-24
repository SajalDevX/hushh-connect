import 'package:flutter/material.dart';

class GradientProgressBar extends StatelessWidget {
  final double progress; // Progress value between 0 and 1
  final double height;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white12, // Background color of the progress bar
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * progress,
              height: height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffe54d60),
                    Color(0xffa342ff),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
