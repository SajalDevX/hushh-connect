import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/components/customTextBox.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';

class AuthCurrentLocation extends StatefulWidget {
  const AuthCurrentLocation({
    super.key,
  });

  @override
  State<AuthCurrentLocation> createState() => _AuthCurrentLocationState();
}

class _AuthCurrentLocationState extends State<AuthCurrentLocation> {
  final TextEditingController _locationController = TextEditingController();
  String? _errorText;
  bool _isLoading = false; // New loading state variable

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch current location when the widget is initialized
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // Show loading indicator when fetching location starts
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        setState(() {
          _isLoading = false; // Stop loading when permission is denied
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocoding
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        setState(() {
          _locationController.text =
              "${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
        });
      } else {
        print('No placemarks found');
      }
    } catch (e) {
      print("Error fetching location: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading when location fetching finishes
      });
    }
  }

  void _validateAndProceed() async {
    final location = _locationController.text;

    if (location.isEmpty) {
      setState(() {
        _errorText = 'Location cannot be empty';
      });
    } else {
      final viewModel = Provider.of<AuthViewModel>(context, listen: false);
      viewModel.updateLocation(location);

      setState(() {
        _errorText = null;
      });

      try {
        await viewModel.updateLocationInProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully!')),
        );
        context.go("/authResume");
      } catch (e) {
        setState(() {
          _errorText = 'Failed to update location. Please try again.';
        });
      }
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
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GradientProgressBar(
                    progress: 0.5, // Set the current step for the email screen
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),
                  Text(
                    'I am staying at',
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
                      prefixIcon: const Icon(Icons.location_city),
                      controller: _locationController,
                      errorText: _errorText,
                      hint: 'Enter your home location...',
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
          if (_isLoading)
            Container(
              width: size.width,
              height: size.height,
              color: Colors.black54, // Overlay background color
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          // Circular Progress Indicator for ViewModel
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
