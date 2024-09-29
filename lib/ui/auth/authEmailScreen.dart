import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/components/customTextBox.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';

class AuthEmailScreen extends StatefulWidget {
  const AuthEmailScreen({super.key});

  @override
  State<AuthEmailScreen> createState() => _AuthEmailScreenState();
}

class _AuthEmailScreenState extends State<AuthEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorText;

  void _validateAndProceed() {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _errorText = 'Email cannot be empty';
      });
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      setState(() {
        _errorText = 'Enter a valid email address';
      });
    } else {
      final viewModel = Provider.of<AuthViewModel>(context, listen: false);
      viewModel.updateEmail(email);
      context.go("/authPhone");
      setState(() {
        _errorText = null; // Clear error message on successful validation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double widthFactor = 0.85; // Set a width factor for responsiveness

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background image
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'lib/assets/images/app_bg.jpeg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add the progress bar at the top
                  const GradientProgressBar(
                    progress: 0.2, // Set the current step for the email screen
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(
                      height: 16), // Add some space after the progress bar
                  // const Icon(
                  //   Icons.close,
                  //   color: Color(0xff7c8591),
                  //   size: 40,
                  // ),
                  const SizedBox(height: 16),
                  Text(
                    'My Email is',
                    style: GoogleFonts.figtree(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffe9ebee),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Make TextField responsive
                  SizedBox(
                    width: size.width * widthFactor,
                    child: Customtextbox(
                      controller: _emailController,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      errorText: _errorText,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Make Button responsive
                  SizedBox(
                    width: size.width * widthFactor,
                    child: IAgreeButton(
                      text: 'Continue',
                      onPressed: _validateAndProceed,
                      size: size.width * widthFactor,
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
}
