// ignore_for_file: sized_box_for_whitespace
import 'package:flutter/material.dart';

class RulesBox extends StatelessWidget {
  final textElemnt1;
  final textElement2;

  const RulesBox({
    super.key,
    required this.textElemnt1,
    required this.textElement2,
  });

  @override
  Widget build(context) {
    return Container(
      width: 354,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textElemnt1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  textElement2,
                  style: const TextStyle(
                    color: Color(0xffb7b6b6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
