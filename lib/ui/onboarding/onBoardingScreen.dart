import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/onboarding/components/rulesTextBox.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void navigateToNextScreen(BuildContext context) {
    context.go("/authName");
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.only(top: 80.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'lib/assets/images/hush_logo.svg',
                    width: 58,
                    height: 76.34,
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'W E L C O M E   T O',
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xffe54d60), Color(0xffa342ff)],
                            tileMode: TileMode.mirror,
                          ).createShader(bounds),
                          child: Text(
                            'hushh Connect',
                            style: GoogleFonts.figtree(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Please follow these house rules',
                          style: GoogleFonts.figtree(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              RulesBox(
                                textElemnt1: 'Be Authentic',
                                textElement2:
                                    'Ensure your profile, including photos and details, is accurate and truthful.',
                              ),
                              RulesBox(
                                textElemnt1: 'Prioritize Privacy',
                                textElement2:
                                    'Keep your personal information safe and interact respectfully with others.',
                              ),
                              RulesBox(
                                textElemnt1: 'Report Concerns',
                                textElement2:
                                    'If you encounter any issues or inappropriate behavior, please report them immediately',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  IAgreeButton(
                    text: 'I Agree',
                    onPressed: () {
                      navigateToNextScreen(context);
                    },
                    size: 127.0,
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
