import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/authOfficeScreen.dart';
import 'package:hushhxtinder/ui/auth/authSocialMediaScreen.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:hushhxtinder/ui/onboarding/components/rulesTextBox.dart';
import 'package:provider/provider.dart';

class AuthResumeScreen extends StatefulWidget {
  const AuthResumeScreen({super.key});

  @override
  State<AuthResumeScreen> createState() => _AuthResumeScreenState();
}

class _AuthResumeScreenState extends State<AuthResumeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  late Animation<Color?> _color3;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for gradient
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // Define color transitions for the animated gradient
    _color1 = ColorTween(
      begin: const Color.fromARGB(255, 214, 75, 75), // Dark Blue
      end: const Color(0xff190087), // Indigo Blue
    ).animate(_controller);

    _color2 = ColorTween(
      begin: const Color(0xffa230ed), // Deeper Indigo
      end: const Color(0xff6b00d7), // Royal Blue
    ).animate(_controller);

    _color3 = ColorTween(
      begin: const Color(0xff3e00b3),
      end: const Color.fromARGB(255, 213, 22, 22), // Deep Violet
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skip() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AuthOfficeScreen()));
  }

  void _showInputFieldsDialog(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    String company = authViewModel.company ?? '';
    String role = authViewModel.role ?? '';
    String tasks = authViewModel.tasks ?? '';

    final TextEditingController companyController =
        TextEditingController(text: company);
    final TextEditingController roleController =
        TextEditingController(text: role);
    final TextEditingController tasksController =
        TextEditingController(text: tasks);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 43, 15, 108),
                Color.fromARGB(255, 95, 17, 97),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Fill in the missing fields',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildGradientTextField(
                  controller: companyController, label: 'Company'),
              const SizedBox(height: 10),
              _buildGradientTextField(
                  controller: roleController, label: 'Role'),
              const SizedBox(height: 10),
              _buildGradientTextField(
                  controller: tasksController, label: 'Tasks'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IAgreeButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      size: 120,
                      text: "Cancel"),
                  IAgreeButton(
                      onPressed: () async {
                        authViewModel.updateOfficeInfo(
                          company: companyController.text,
                          role: roleController.text,
                          tasks: tasksController.text,
                        );
                        if (companyController.text.isNotEmpty &&
                            roleController.text.isNotEmpty &&
                            tasksController.text.isNotEmpty) {
                          await authViewModel.uploadOfficeInfoToSupabase();
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AuthSocialMediaScreen(),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                          _showInputFieldsDialog(context);
                        }
                      },
                      size: 120,
                      text: 'OK')
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientTextField(
      {required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleUploadResume(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.uploadResumeAndExtractText();
    _showInputFieldsDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double widthFactor = 0.85;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _color1.value ?? Colors.deepPurpleAccent,
                      _color2.value ?? Colors.blueAccent,
                      _color3.value ?? Colors.pinkAccent,
                    ],
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const GradientProgressBar(progress: 0.2),
                  const SizedBox(height: 36),
                  Text(
                    'Upload Your Resume',
                    style: GoogleFonts.figtree(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffe9ebee),
                    ),
                  ),
                  const Spacer(),
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        RulesBox(
                          textElemnt1: 'Showcase Your Skills',
                          textElement2:
                              'Upload your resume to highlight your unique qualifications and experiences.',
                        ),
                        RulesBox(
                          textElemnt1: 'Enhance Your Visibility',
                          textElement2:
                              'Increase your chances of being discovered by recruiters in the job market.',
                        ),
                        RulesBox(
                          textElemnt1: 'Streamline Applications',
                          textElement2:
                              ' Make applying for jobs quicker and easier with your resume on file.',
                        ),
                        RulesBox(
                          textElemnt1: 'Receive Tailored Opportunities',
                          textElement2:
                              'Get personalized job recommendations based on your skills and experiences.',
                        ),
                        RulesBox(
                          textElemnt1: 'Take Control of Your Career',
                          textElement2:
                              'Start your journey toward new opportunities by sharing your resume today!',
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: size.width * widthFactor,
                    child: IAgreeButton(
                      text: 'Upload Resume',
                      onPressed: () => _handleUploadResume(context),
                      size: size.width * widthFactor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: size.width * widthFactor,
                    child: ElevatedButton(
                      onPressed: _skip,
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 36,
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
