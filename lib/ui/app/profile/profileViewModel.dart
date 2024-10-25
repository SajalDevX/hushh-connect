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
        if (data['images'] is String) {
          imageUrls = List<String>.from(json.decode(data['images']));
        } else if (data['images'] is List) {
          imageUrls = List<String>.from(data['images']);
        }
      }

      // Check for 'socialmedia'
      Map<String, String>? socialmedia;
      if (data['socialmedia'] != null) {
        socialmedia =
            Map<String, String>.from(json.decode(data['socialmedia']));
      }

      // Check for 'passions'
      List<String>? passions;
      if (data['passions'] != null) {
        passions = List<String>.from(json.decode(data['passions']));
      }

      // Check for 'office_details'
      Map<String, dynamic>? officeDetails;
      if (data['office_details'] != null && data['office_details'] is String) {
        officeDetails = jsonDecode(data['office_details']);
      }

      print('Office details: $officeDetails');

      profile = ProfileData(
          uid: data['id'] ?? 'null',
          name: data['name'] ?? 'Unknown',
          images: imageUrls,
          profile_img: imageUrls.isNotEmpty ? imageUrls[0] : '',
          homeLoc: data['current_address'] ?? '',
          officeDetails:
              officeDetails != null ? jsonEncode(officeDetails) : null,
          passions: passions,
          socialmedia: socialmedia,
          email: data['email'] ?? 'Unknown');

      return profile;
    } catch (e) {
      print('Exception in viewmodel: $e');
      return null;
    } finally {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> addImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      isLoading = true;
      notifyListeners(); // Notify listeners to update UI

      try {
        final ref = _firebaseStorage.ref().child(
            'user_images/${FirebaseAuth.instance.currentUser?.uid}/${pickedFile.name}');
        UploadTask uploadTask = ref.putFile(File(pickedFile.path));

        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        imageUrls.add(downloadUrl);

        await _updateProfileImages(); // Update the user's profile images if needed
      } catch (e) {
        print('Error uploading image: $e');
      } finally {
        isLoading = false;
        notifyListeners(); // Notify listeners to hide the progress indicator
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
    if (profile!.profile_img.isNotEmpty) filledFields++;
    if (profile!.homeLoc?.isNotEmpty ?? false) filledFields++;
    if (profile!.officeDetails?.isNotEmpty ?? false) filledFields++;
    if (profile!.socialmedia != null && profile!.socialmedia!.isNotEmpty)
      filledFields++;
    if (profile!.passions != null && profile!.passions!.isNotEmpty)
      filledFields++;

    return (filledFields / totalFields) * 100.0;
  }

  Future<bool> editUserProfile(
      String? name, String? email, Map<String, String>? officeDetails) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User is not logged in.');
      }

      // Build the updated user map
      Map<String, dynamic> updatedUser = {};
      if (name != null && name.isNotEmpty) {
        updatedUser['name'] = name;
      }
      if (email != null && email.isNotEmpty) {
        updatedUser['email'] = email;
      }
      if (officeDetails != null && officeDetails.isNotEmpty) {
        updatedUser['office_details'] = jsonEncode(officeDetails);
      }

      if (updatedUser.isEmpty) {
        print('No changes to update');
        return false;
      }

      await supabaseClient
          .from('users')
          .update(updatedUser)
          .eq('id', currentUserId); // Ensure that execute() is awaited

      // Reload the user profile after updating
      await fetchUser();

      return true;
    } catch (e) {
      print('Exception: $e');
      return false;
    } finally {
      notifyListeners();
      isLoading = false;
    }
  }

}
