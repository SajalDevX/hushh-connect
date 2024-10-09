import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with existing values from the viewmodel if needed
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _instagramController.text = authViewModel.instagram;
    _linkedInController.text = authViewModel.linkedin;
    _youtubeController.text = authViewModel.youtube;
    _twitterController.text = authViewModel.twitter;
    _otherLinkController.text = authViewModel.other;
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _linkedInController.dispose();
    _youtubeController.dispose();
    _twitterController.dispose();
    _otherLinkController.dispose();
    super.dispose();
  }

  void _updateSocialMediaLinks() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.updateInstagram(_instagramController.text.trim());
    authViewModel.updateLinkedIn(_linkedInController.text.trim());
    authViewModel.updateYouTube(_youtubeController.text.trim());
    authViewModel.updateTwitter(_twitterController.text.trim());
    authViewModel.updateOther(_otherLinkController.text.trim());
  }

  Future<void> onNext() async {
    setState(() {
      _isLoading = true;
    });

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _updateSocialMediaLinks(); // Update the ViewModel with the latest input
    await authViewModel.uploadSocialMediaLinksToSupabase();

    setState(() {
      _isLoading = false;
    });

    context.go("/authPhotos");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double commonWidth = size.width * 0.85;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GradientProgressBar(
                    progress: 0.7,
                  ),
                  const SizedBox(height: 16),
                  // IconButton(
                  //   icon: const Icon(Icons.close, color: Color(0xff7c8591)),
                  //   onPressed: () {
                  //     authViewModel.updateProgress(9);
                  //     context.go("/authPhotos");
                  //   },
                  //   iconSize: 40,
                  // ),
                  const SizedBox(height: 36),
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
                    onChanged: _updateSocialMediaLinks,
                  ),
                  const SizedBox(height: 8),
                  _buildSocialMediaTextBox(
                    iconPath: 'lib/assets/images/linkedin.png',
                    hintText: 'Enter your LinkedIn username...',
                    controller: _linkedInController,
                    size: size,
                    onChanged: _updateSocialMediaLinks,
                  ),
                  const SizedBox(height: 8),
                  _buildSocialMediaTextBox(
                    iconPath: 'lib/assets/images/youtube.png',
                    hintText: 'Enter your YouTube channel name...',
                    controller: _youtubeController,
                    size: size,
                    onChanged: _updateSocialMediaLinks,
                  ),
                  const SizedBox(height: 8),
                  _buildSocialMediaTextBox(
                    iconPath: 'lib/assets/images/twitter.png',
                    hintText: 'Enter your Twitter username...',
                    controller: _twitterController,
                    size: size,
                    onChanged: _updateSocialMediaLinks,
                  ),
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
                    onChanged: _updateSocialMediaLinks,
                  ),
                  const SizedBox(height: 64),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
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
    required void Function() onChanged,
  }) {
    return SizedBox(
      width: size.width * 0.85,
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
