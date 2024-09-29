import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/components/customTextBox.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';

class AuthPhoneScreen extends StatefulWidget {
  const AuthPhoneScreen({
    super.key,
  });

  @override
  State<AuthPhoneScreen> createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen> {
  String? _errorText; // Track the error message

  void _validateAndProceed() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final phone = viewModel.phoneController.text;
    if (phone.isEmpty) {
      setState(() {
        _errorText = 'Phone number cannot be empty';
      });
    } else if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone)) {
      setState(() {
        _errorText = 'Enter a valid phone number';
      });
    } else {
      final fullPhoneNumber = '+91$phone';
      viewModel.updatePhoneNumber(fullPhoneNumber);

      setState(() {
        _errorText =
            null; // Clear error message before starting the async operation
      });

      // Show loading indicator while phone number verification is in progress
      await viewModel.verifyPhoneNumber(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully!')),
      );
      context.go("/authOtp");
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
                  const GradientProgressBar(
                    progress: 0.3, // Set the current step for the email screen
                  ),
                  const SizedBox(height: 16),

                  // const Icon(
                  //   Icons.close,
                  //   color: Color(0xff7c8591),
                  //   size: 40,
                  // ),
                  const SizedBox(height: 16),
                  Text(
                    'My Phone Number is',
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
                      controller:
                          Provider.of<AuthViewModel>(context).phoneController,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
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
          // Circular Progress Indicator
          Consumer<AuthViewModel>(
            builder: (context, viewModel, child) {
              return viewModel.isLoading
                  ? Container(
                      width: size.width,
                      height: size.height,
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
