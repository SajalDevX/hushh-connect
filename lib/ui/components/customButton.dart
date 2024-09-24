import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IAgreeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final String text;

  const IAgreeButton(
      {super.key,
      required this.onPressed,
      required this.size,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ensure there is no shadow by setting elevation to 0 and removing BoxShadow
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffe54d60),
            Color(0xffa342ff),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(27),
      ),
      child: SizedBox(
        width: size,
        height: 44,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.transparent, // Make the button background transparent
            foregroundColor: Colors.white,
            elevation: 0, // Remove shadow/elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          child: Text(
            text,
            style:
                GoogleFonts.figtree(fontSize: 19, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
