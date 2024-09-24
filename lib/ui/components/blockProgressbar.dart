import 'package:flutter/material.dart';

class BlockProgressBar extends StatelessWidget {
  final double progress; // Progress value between 0 and 1
  final int totalBlocks;
  final double height;
  final double spacing;

  const BlockProgressBar({
    Key? key,
    required this.progress,
    this.totalBlocks = 10,
    this.height = 10.0,
    this.spacing = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int filledBlocks = (progress * totalBlocks).round();

    return Row(
      children: List.generate(totalBlocks, (index) {
        bool isFilled = index < filledBlocks;
        return Expanded(
          child: Container(
            height: height,
            margin:
                EdgeInsets.only(right: index < totalBlocks - 1 ? spacing : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              color: isFilled
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : Colors.black12,
            ),
          ),
        );
      }),
    );
  }
}
