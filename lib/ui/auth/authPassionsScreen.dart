import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPassionsScreen extends StatefulWidget {
  const AuthPassionsScreen({super.key});

  @override
  _AuthPassionsScreenState createState() => _AuthPassionsScreenState();
}

class _AuthPassionsScreenState extends State<AuthPassionsScreen> {
  // List of passions
  final List<String> passions = [
    "90's kid",
    "Harry Potter",
    "SoundCloud",
    "Spa",
    "Self-care",
    "Heavy metal",
    "House parties",
    "Gin & tonic",
    "Gymnastics",
    "Ludo",
    "Maggi",
    "Hot yoga",
    "Biryani",
    "Meditation",
    "Sushi",
    "Spotify",
    "Hockey",
    "Basketball",
    "Slam poetry",
    "Home workouts",
    "Theatre",
    "Café hopping",
    "Trainers",
    "Aquarium",
    "Instagram",
    "Hot springs",
    "Walking",
    "Running",
    "Travel",
    "Language exchange",
    "Films",
    "Guitarists",
    "Social development",
    "Gym",
    "Social media",
    "Hip hop",
    "Skincare",
    "J-Pop",
    "Cricket",
    "Shisha",
    "Freelance",
    "K-Pop",
    "Skateboarding"
  ];

  // Track selected passions
  Set<String> selectedPassions = {};

  @override
  Widget build(BuildContext context) {
    final authViewModel =
        Provider.of<AuthViewModel>(context); // Access ViewModel

    void onNext() async {
      if (selectedPassions.length >= 5) {
        // Update passions and handle navigation
        await authViewModel.updatePassions(selectedPassions.toList());
        if (!authViewModel.isLoading) {
          context.go('/main');
        }
      }
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/app_bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                const GradientProgressBar(
                  progress: 0.9,
                ),
                const SizedBox(height: 16),
                // IconButton(
                //   icon: const Icon(Icons.close, color: Color(0xff7c8591)),
                //   onPressed: () {
                //     authViewModel.updateProgress(11);
                //     context.go('/main');
                //   },
                //   iconSize: 40,
                // ),
                const SizedBox(height: 8),
                Text(
                  'Passions',
                  style: GoogleFonts.figtree(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xffe9ebee),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let everyone know what you're passionate about by adding it to your profile.",
                  style: GoogleFonts.figtree(
                    fontSize: 16,
                    color: const Color(0xff7c8591),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: passions.map(
                    (passion) {
                      final isSelected = selectedPassions.contains(passion);
                      return ChoiceChip(
                        label: Text(passion),
                        labelStyle: GoogleFonts.figtree(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xff939ba7),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedPassions.add(passion);
                            } else {
                              selectedPassions.remove(passion);
                            }
                          });
                        },
                        showCheckmark: false,
                        selectedColor: Colors.pinkAccent,
                        backgroundColor: const Color(0xff3b3b4f),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.pinkAccent
                                : Colors.transparent,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          // Continue Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              child: authViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedPassions.isNotEmpty
                            ? Colors.pinkAccent
                            : const Color(0xff3b3b4f),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Continue (${selectedPassions.length}/5)",
                        style: GoogleFonts.figtree(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
