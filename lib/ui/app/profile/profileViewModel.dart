import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/models/profile_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileViewModel extends ChangeNotifier {
  bool isLoading = false;
  ProfileData? profile;
  List<String> imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<ProfileData?> fetchUser() async {
    if (isLoading) return profile;

    isLoading = true;
    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      final response = await supabaseClient
          .from('users')
          .select()
          .eq('id', currentUserId)
          .single();

      final data = response;

      if (data['images'] != null) {
        imageUrls = List<String>.from(json.decode(data['images']));
      }

      Map<String, String>? socialmedia;
      if (data['socialmedia'] != null) {
        socialmedia =
            Map<String, String>.from(json.decode(data['socialmedia']));
      }

      // Parse passions as a list of strings
      List<String>? passions;
      if (data['passions'] != null) {
        passions = List<String>.from(json.decode(data['passions']));
      }

      // Office details stored as a JSON object
      String? officeDetails;
      if (data['office_details'] != null) {
        officeDetails = jsonEncode(data['office_details']);
      }

      // Create a ProfileData object
      profile = ProfileData(
        name: data['name'] ?? 'Unknown',
        imageurl: imageUrls.isNotEmpty ? imageUrls[0] : '',
        homeLoc: data['current_address'] ?? '',
        officeDetails: officeDetails,
        passions: passions,
        socialmedia: socialmedia,
      );

      return profile;
    } catch (e) {
      print('Exception: $e');
      return null;
    } finally {
      isLoading = false;
      // Call notifyListeners() outside of the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> addImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        // Upload to Firebase Storage (optional: also use Supabase Storage if needed)
        final ref = _firebaseStorage.ref().child(
            'user_images/${FirebaseAuth.instance.currentUser?.uid}/${pickedFile.name}');
        UploadTask uploadTask = ref.putFile(File(pickedFile.path));
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        // Add image URL to the list
        imageUrls.add(downloadUrl);

        // Update the profile in Supabase
        await _updateProfileImages();
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> removeImage(int index) async {
    String imageUrl = imageUrls[index];
    imageUrls.removeAt(index);

    try {
      // Delete from Firebase Storage
      Reference imageRef = _firebaseStorage.refFromURL(imageUrl);
      await imageRef.delete();

      // Update the profile in Supabase
      await _updateProfileImages();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<void> _updateProfileImages() async {
    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      // Update the 'images' field in Supabase
      await supabaseClient
          .from('users')
          .update({'images': json.encode(imageUrls)}).eq('id', currentUserId);

      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  double getProfileCompletionPercentage() {
    if (profile == null) return 0.0;

    int filledFields = 0;
    final totalFields = 6; // Number of fields to check

    if (profile!.name.isNotEmpty) filledFields++;
    if (profile!.imageurl.isNotEmpty) filledFields++;
    if (profile!.homeLoc?.isNotEmpty ?? false) filledFields++;
    if (profile!.officeDetails?.isNotEmpty ?? false) filledFields++;
    if (profile!.socialmedia != null && profile!.socialmedia!.isNotEmpty)
      filledFields++;
    if (profile!.passions != null && profile!.passions!.isNotEmpty)
      filledFields++;

    return (filledFields / totalFields) * 100.0;
  }
}
