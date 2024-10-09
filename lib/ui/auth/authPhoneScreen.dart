import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/components/country_code_text_field.dart';
import 'package:provider/provider.dart';
import 'package:hushhxtinder/data/models/countriesModel.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customTextBox.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';

class AuthPhoneScreen extends StatefulWidget {
  const AuthPhoneScreen({Key? key}) : super(key: key);

  @override
  State<AuthPhoneScreen> createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen> {
  Country? selectedCountry;
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set India as the default country on initial load
    selectedCountry = countries.firstWhere((country) => country.code == "IN");
  }

  void _validateAndProceed() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final phone = phoneController.text;

    // Check if phone number is empty
    if (phone.isEmpty) {
      _showSnackBar('Phone number cannot be empty');
      return;
    }
    if (phone.length < selectedCountry!.minLength ||
        phone.length > selectedCountry!.maxLength) {
      _showSnackBar(
          'Phone number must be between ${selectedCountry?.minLength} and ${selectedCountry?.maxLength} digits for ${selectedCountry?.name}.');
      return;
    }

    // Concatenate dial code and phone number
    final fullPhoneNumber = '+${selectedCountry?.dialCode ?? '+91'}$phone';
    viewModel.updatePhoneNumber(fullPhoneNumber);

    await viewModel.verifyPhoneNumber(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent successfully!')),
    );
    context.go("/authOtp");
  }

  void _showSnackBar(String message) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: isKeyboardOpen
            ? MediaQuery.of(context).viewInsets.bottom + 2.0
            : 10.0,
        left: 16.0,
        right: 16.0,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _pickCountryCode() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CountrySelectionScreen()),
    );

    if (selected != null && selected is Country) {
      setState(() {
        selectedCountry = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double widthFactor = 0.85;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GradientProgressBar(progress: 0.3),
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
                  Row(
                    children: [
                      // Country Code Picker (Flag and Dial Code)
                      GestureDetector(
                        onTap: _pickCountryCode,
                        child: Row(
                          children: [
                            Image.asset(
                              "lib/assets/flags/${selectedCountry?.code.toLowerCase()}.png",
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${selectedCountry?.dialCode ?? '+91'}',
                              style: GoogleFonts.figtree(
                                fontSize: 18,
                                color: const Color(0xffe9ebee),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Phone Number Text Box
                      Expanded(
                        child: Customtextbox(
                          controller: phoneController,
                          hint: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  // Continue Button
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
