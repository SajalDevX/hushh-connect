// ignore_for_file: sort_child_properties_last, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hushhxtinder/data/models/profile_model.dart';

class GenerateQrPromptScreen extends StatefulWidget {
  final ProfileData profile;

  const GenerateQrPromptScreen({super.key, required this.profile});
  @override
  _GenerateQrPromptScreenState createState() => _GenerateQrPromptScreenState();
}

class _GenerateQrPromptScreenState extends State<GenerateQrPromptScreen> {
  bool _qrGenerated = false;

  @override
  void initState() {
    super.initState();
    _checkQrGenerated();
  }

  Future<void> _checkQrGenerated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool qrGenerated = prefs.getBool('qrGenerated') ?? false;
    setState(() {
      _qrGenerated = qrGenerated;
    });

    if (_qrGenerated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QrScreen(data: widget.profile),
        ),
      );
    }
  }

  Future<void> _generateQrCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('qrGenerated', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QrScreen(data: widget.profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg', // Your background image
              fit: BoxFit.cover,
            ),
          ),
          _qrGenerated
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'You haven\'t generated a QR code yet.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _generateQrCode,
                  child: const Text('Generate QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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

class QrScreen extends StatelessWidget {
  final ProfileData data;
  const QrScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String qrData = 'https://stumato.store/profile/${data.uid}';

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/app_bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              iconSize: 28,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          // Heading positioned at the top center
          const Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Text(
              "QR Code",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(data.profile_img),
                radius: 32,
              ),
              const SizedBox(height: 8),
              Text(
                data.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'WhatsApp contact',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 300,
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.white,
                ),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.white,
                ),
                gapless: false,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your QR code is private. If you share it with someone,\nthey can scan it with their camera to see your\nprofile.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                },
                child: const Text(
                  'Reset QR code',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Share.share('Check out this profile: ${data.name}');
                },
                child: const Text('Share QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
