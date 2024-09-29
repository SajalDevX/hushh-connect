import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/components/customTextBox.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';

class AuthOtpScreen extends StatefulWidget {
  const AuthOtpScreen({super.key});

  @override
  State<AuthOtpScreen> createState() => _AuthOtpScreenState();
}

class _AuthOtpScreenState extends State<AuthOtpScreen> {
  String? _errorText;

  void _validateAndProceed() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final otp = viewModel.otpController.text;
    if (otp.isEmpty) {
      setState(() {
        _errorText = 'OTP cannot be empty';
      });
    } else if (otp.length != 6) {
      setState(() {
        _errorText = 'Enter a valid 6-digit OTP';
      });
    } else {
      setState(() {
        _errorText =
            null; // Clear error message before starting the async operation
      });

      // Start the loading state and verify OTP
      viewModel.isLoading = true;
      await viewModel.verifyOtp(context);

      viewModel.isLoading = false;
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
                    progress: 0.4, // Set the current step for the email screen
                  ),
                  const SizedBox(height: 16),

                  // const Icon(
                  //   Icons.close,
                  //   color: Color(0xff7c8591),
                  //   size: 40,
                  // ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter the OTP',
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
                          Provider.of<AuthViewModel>(context).otpController,
                      hint: 'Enter OTP',
                      keyboardType: TextInputType.number,
                      errorText: _errorText,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Make Button responsive
                  SizedBox(
                    width: size.width * widthFactor,
                    child: Consumer<AuthViewModel>(
                      builder: (context, viewModel, child) {
                        return viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : IAgreeButton(
                                text: 'Continue',
                                onPressed: _validateAndProceed,
                                size: size.width * 0.85, // Responsive size
                              );
                      },
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
