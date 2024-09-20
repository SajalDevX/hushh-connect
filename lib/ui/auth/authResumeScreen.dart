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

class _AuthResumeScreenState extends State<AuthResumeScreen> {
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
        builder: (context) => AlertDialog(
              title: Text(
                'Fill in the missing fields',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: companyController,
                      decoration: InputDecoration(
                        labelText: 'Company',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    SizedBox(height: 10), // Spacing between fields
                    TextField(
                      controller: roleController,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: tasksController,
                      decoration: InputDecoration(
                        labelText: 'Tasks',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red, // Cancel button color
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    authViewModel.updateOfficeInfo(
                      company: companyController.text,
                      role: roleController.text,
                      tasks: tasksController.text,
                    );

                    // Check if all fields are filled
                    if (companyController.text.isNotEmpty &&
                        roleController.text.isNotEmpty &&
                        tasksController.text.isNotEmpty) {
                      await authViewModel.uploadOfficeInfoToSupabase();
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthSocialMediaScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop(); // Close the dialog
                      _showInputFieldsDialog(context); // Show the dialog again
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Button color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('OK'),
                ),
              ],
            ));
  }

  void _handleUploadResume(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Resume upload and text extraction
    await authViewModel.uploadResumeAndExtractText();

    // Show input fields dialog for extracted data
    _showInputFieldsDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double widthFactor = 0.85;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/app_bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
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
                  Spacer(),
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
                  Spacer(),
                  SizedBox(
                    width: size.width * widthFactor,
                    child: IAgreeButton(
                      text: 'Upload Resume',
                      onPressed: () => _handleUploadResume(context),
                      size: size.width * widthFactor,
                    ),
                  ),
                  SizedBox(height: 16),
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
