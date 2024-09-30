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
                  child:
                      CircularProgressIndicator()) // Showing loader when generated
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'You haven\'t generated a QR code yet.',
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              Colors.white, // White text to contrast background
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _generateQrCode,
                        child: const Text('Generate QR Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepPurple, // Customize button color
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
        children: [
          // Background image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'lib/assets/images/app_bg.jpeg'), // Background image
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Container(
                    height: 410,
                    width: 350,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 296,
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color.fromARGB(255, 126, 13, 146),
                          ),
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color.fromARGB(255, 79, 9, 93),
                          ),
                          gapless: false,
                        ),
                        const SizedBox(height: 16),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "@${data.name.toUpperCase()}",
                            style: GoogleFonts.figtree(
                              fontWeight: FontWeight.w600,
                              fontSize: 32,
                              color: const Color.fromARGB(255, 113, 16, 130),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Container(
                  height: 72,
                  width: 350,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: IconButton(
                    icon: const Icon(Icons.share,
                        color: Color.fromARGB(255, 97, 24, 130)),
                    onPressed: () {
                      String profileLink =
                          'https://stumato.store/profile/${data.uid}';
                      Share.share(
                          'Check out this profile: ${data.name}.\n$profileLink');
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
