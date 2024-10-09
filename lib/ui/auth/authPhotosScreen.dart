import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/ui/auth/authPassionsScreen.dart';
import 'package:hushhxtinder/ui/auth/viewmodel/authViewodel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:hushhxtinder/ui/onboarding/components/customProgressIndicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Auth

class AuthPhotosScreen extends StatefulWidget {
  const AuthPhotosScreen({super.key});

  @override
  _AuthPhotosScreenState createState() => _AuthPhotosScreenState();
}

class _AuthPhotosScreenState extends State<AuthPhotosScreen> {
  final List<File?> _images = List.generate(6, (_) => null);
  final AuthViewModel _viewModel = AuthViewModel(); // Initialize ViewModel
  bool _isLoading = false; // Add a loading state

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images[index] = File(pickedFile.path);
      });
    } else {
      print('No image selected');
    }
  }

  Future<File?> compressImage(File file) async {
    final targetPath = '${file.parent.path}/temp.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // Adjust quality to compress
    );

    return result;
  }

  Future<void> _uploadImages() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final storage = FirebaseStorage.instance;
    final List<String> imageUrls = [];

    for (var i = 0; i < _images.length; i++) {
      if (_images[i] != null) {
        final file = _images[i]!;

        // Compress image before upload
        final compressedFile = await compressImage(file);
        if (compressedFile == null) {
          print('Failed to compress image');
          continue;
        }

        final ref = storage.ref().child('user_photos/${user.uid}/photo$i');
        try {
          final uploadTask = ref.putFile(compressedFile);

          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {});

          await uploadTask;
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        } on FirebaseException catch (e) {
          print('Firebase error: ${e.message}');
        } catch (e) {
          print('Unexpected error occurred: $e');
        }
      }
    }

    print('Uploaded Image URLs: $imageUrls');
    await _viewModel.uploadImagesToSupabase(imageUrls);

    setState(() {
      _isLoading = false;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images[index] = null;
    });
  }

  void onNext() async {
    int selectedImageCount = _images.where((image) => image != null).length;
    if (selectedImageCount < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 4 images to continue.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await _uploadImages(); // Upload images before navigating
    if (!_isLoading) {
      context.go("/authPassions");
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthViewModel authViewModel = AuthViewModel(); // Initialize ViewModel

    final size = MediaQuery.of(context).size;
    final double photoWidth = size.width * 0.28; // Width for each image box
    final double photoHeight = size.height * 0.2; // Height for each image box
    final double spacing = size.width * 0.04; // Spacing between image boxes

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GradientProgressBar(
                    progress: 0.8, // Set the current step for the email screen
                  ),
                  const SizedBox(height: 16),
                  // IconButton(
                  //   icon: const Icon(Icons.close, color: Color(0xff7c8591)),
                  //   onPressed: () {
                  //     authViewModel.updateProgress(10);
                  //     context.go("/authPassions");
                  //   },
                  //   iconSize: 40,
                  // ),
                  const SizedBox(height: 36),
                  Text(
                    'Add Photos',
                    style: GoogleFonts.figtree(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffe9ebee),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add at least 4 photos to continue',
                    style: GoogleFonts.figtree(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffe9ebee),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _pickImage(index),
                          child: SizedBox(
                            width: photoWidth,
                            height: photoHeight,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: photoWidth,
                                  height: photoHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: _images[index] == null
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xffdcdfe6),
                                            borderRadius:
                                                BorderRadius.circular(7),
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.file(
                                            _images[index]!,
                                            width: photoWidth,
                                            height: photoHeight,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                Positioned(
                                  bottom: -10,
                                  right: -10,
                                  child: GestureDetector(
                                    onTap: _images[index] == null
                                        ? () => _pickImage(index)
                                        : () => _removeImage(index),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.pinkAccent,
                                      ),
                                      child: Icon(
                                        _images[index] == null
                                            ? Icons.add
                                            : Icons.close,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 36),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: IAgreeButton(
                            text: 'Continue',
                            onPressed: onNext,
                            size: double.infinity,
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
