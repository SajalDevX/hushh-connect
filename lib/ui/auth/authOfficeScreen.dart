// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/authSocialMediaScreen.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/components/customTextBox.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';

class AuthOfficeScreen extends StatefulWidget {
  const AuthOfficeScreen({super.key});

  @override
  _AuthOfficeScreenState createState() => _AuthOfficeScreenState();
}

class _AuthOfficeScreenState extends State<AuthOfficeScreen> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _tasksController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _tasksController.dispose();
    super.dispose();
  }

  void onNext() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.updateOfficeInfo(
      company: _companyController.text,
      role: _roleController.text,
      tasks: _tasksController.text,
    );

    // Upload office info to Supabase
    await authViewModel.uploadOfficeInfoToSupabase();

    context.go("/authSocialMedia");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double commonWidth = size.width * 0.9;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return Stack(
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
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GradientProgressBar(
                        progress:
                            0.6, // Set the current step for the email screen
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 8),
                      Text(
                        'I work at',
                        style: GoogleFonts.figtree(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xffe9ebee),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: commonWidth,
                        child: Customtextbox(
                          hint: 'Enter your company name...',
                          controller: _companyController,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'MY OFFICE ROLE IS',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xffe9ebee),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: commonWidth,
                        child: Customtextbox(
                          hint: 'Enter your role...',
                          controller: _roleController,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'MY OFFICE TASKS WILL INCLUDE',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xffe9ebee),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: commonWidth,
                        child: Customtextbox(
                          height: 291,
                          hint: 'Enter your tasks...',
                          maxLines: 10,
                          controller: _tasksController,
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: commonWidth,
                        child: authViewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : IAgreeButton(
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
          );
        },
      ),
    );
  }
}
