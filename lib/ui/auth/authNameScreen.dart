import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/components/customTextBox.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';

class AuthNameScreen extends StatefulWidget {
  const AuthNameScreen({super.key});

  @override
  State<AuthNameScreen> createState() => _AuthNameScreenState();
}

class _AuthNameScreenState extends State<AuthNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText; // Track the error message

  void _validateAndProceed() {
    final name = _nameController.text;

    if (name.isEmpty) {
      setState(() {
        _errorText = 'Name cannot be empty';
      });
    } else {
      final viewModel = Provider.of<AuthViewModel>(context, listen: false);
      viewModel.updateName(name);
      context.go("/authEmail");
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
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.03), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GradientProgressBar(
                    progress: 0.1, // Set the current step for the email screen
                  ),
                  const SizedBox(height: 16),

                  // const Icon(
                  //   Icons.close,
                  //   color: Color(0xff7c8591),
                  //   size: 40,
                  // ),
                  const SizedBox(height: 16),
                  Text(
                    'My Name is',
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
                      controller: _nameController,
                      hint: 'Enter your name',
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
