import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
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
        ],
      ),
    );
  }
}
