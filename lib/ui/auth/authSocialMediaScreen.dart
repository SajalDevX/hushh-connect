import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/authOfficeScreen.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/components/customTextBox.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';

class AuthSocialMediaScreen extends StatefulWidget {
  const AuthSocialMediaScreen({super.key});

  @override
  _AuthSocialMediaScreenState createState() => _AuthSocialMediaScreenState();
}

class _AuthSocialMediaScreenState extends State<AuthSocialMediaScreen> {
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _otherLinkController = TextEditingController();
  bool _isLoading = false; // Add a loading state

  @override
  void dispose() {
    _instagramController.dispose();
    _linkedInController.dispose();
    _youtubeController.dispose();
    _twitterController.dispose();
    _otherLinkController.dispose();
    super.dispose();
  }

  String _buildSocialMediaLink(String baseUrl, String username) {
    if (username.startsWith('http://') || username.startsWith('https://')) {
      return username;
    }
    return '$baseUrl$username';
  }

  Future<void> onNext() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final instagramLink = _instagramController.text.isEmpty
        ? null
        : _buildSocialMediaLink(
            'https://www.instagram.com/', _instagramController.text);
    final twitterLink = _twitterController.text.isEmpty
        ? null
        : _buildSocialMediaLink(
            'https://www.twitter.com/', _twitterController.text);
    final youtubeLink = _youtubeController.text.isEmpty
        ? null
        : _buildSocialMediaLink(
            'https://www.youtube.com/', _youtubeController.text);
    final linkedinLink = _linkedInController.text.isEmpty
        ? null
        : _buildSocialMediaLink(
            'https://www.linkedin.com/in/', _linkedInController.text);
    final otherLink =
        _otherLinkController.text.isEmpty ? null : _otherLinkController.text;

    authViewModel.updateSocialMedia(
      instagram: instagramLink,
      twitter: twitterLink,
      youtube: youtubeLink,
      linkedin: linkedinLink,
      other: otherLink,
    );

    await authViewModel.uploadSocialMediaLinksToSupabase();

    setState(() {
      _isLoading = false; // Stop loading
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthOfficeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double commonWidth = size.width * 0.9;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GradientProgressBar(
                  progress: 0.7, // Set the current step for the email screen
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xff7c8591)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  iconSize: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sync with social media',
                  style: GoogleFonts.figtree(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xffe9ebee),
                  ),
                ),
                const SizedBox(height: 36),
                _buildSocialMediaTextBox(
                  iconPath: 'lib/assets/images/instagram.png',
                  hintText: 'Enter your Instagram username...',
                  controller: _instagramController,
                  size: size,
                ),
                const SizedBox(height: 8),
                _buildSocialMediaTextBox(
                  iconPath: 'lib/assets/images/linkedin.png',
                  hintText: 'Enter your LinkedIn username...',
                  controller: _linkedInController,
                  size: size,
                ),
                const SizedBox(height: 8),
                _buildSocialMediaTextBox(
                  iconPath: 'lib/assets/images/youtube.png',
                  hintText: 'Enter your YouTube channel name...',
                  controller: _youtubeController,
                  size: size,
                ),
                const SizedBox(height: 8),
                _buildSocialMediaTextBox(
                  iconPath: 'lib/assets/images/twitter.png',
                  hintText: 'Enter your Twitter username...',
                  controller: _twitterController,
                  size: size,
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 64),
                Center(
                  child: Text(
                    'Add any other links...',
                    style: GoogleFonts.figtree(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSocialMediaTextBox(
                  iconPath: 'lib/assets/images/link.png',
                  hintText: 'Paste your link here...',
                  controller: _otherLinkController,
                  suffixIconPath: 'lib/assets/images/button.png',
                  size: size,
                ),
                const SizedBox(height: 64),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: commonWidth,
                        child: IAgreeButton(
                          text: 'Continue',
                          onPressed: onNext,
                          size: commonWidth,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaTextBox({
    required String iconPath,
    required String hintText,
    required TextEditingController controller,
    String? suffixIconPath,
    required Size size,
  }) {
    return SizedBox(
      width: size.width * 0.9,
      child: Customtextbox(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(iconPath, width: 24, height: 24),
        ),
        suffixIcon: suffixIconPath != null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(suffixIconPath, width: 24, height: 24),
              )
            : null,
        hint: hintText,
        keyboardType: TextInputType.url,
        controller: controller,
      ),
    );
  }
}
