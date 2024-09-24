import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/models/productModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Productviewmodel extends ChangeNotifier {
  bool isLoading = false;
  List<Product> products = [];

  Future<void> fetchProducts() async {
    final _supabase = Supabase.instance.client;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    try {
      isLoading = true;
      notifyListeners();
      final response = await _supabase
          .from("product_table")
          .select()
          .eq('userId', currentUserId!)
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      products = data
          .map((item) => Product(
              productImageUrl: item['image'],
              link: item["product_link"],
              productname: item['name'],
              productContent: item['description'],
              productPrice: item['price']))
          .toList();
    } catch (error) {
      print('Error fetching products $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProduct({
    required File imageFile,
    required String productName,
    required String productContent,
    required double productPrice,
    required String productLink,
  }) async {
    try {
      String? imageUrl = await uploadImageToFirebase(imageFile);
      if (imageUrl == null) {
        throw 'Failed to upload image';
      }

      await _uploadProductToSupabase(
        imageUrl: imageUrl,
        productName: productName,
        productContent: productContent,
        productPrice: productPrice,
        productLink: productLink,
      );

      notifyListeners();
    } catch (e) {
      print('Error uploading product: $e');
    }
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'product_images/$currentUserId/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase: $e');
      return null;
    }
  }

  Future<void> _uploadProductToSupabase({
    required String imageUrl,
    required String productName,
    required String productContent,
    required double productPrice,
    required String productLink,
  }) async {
    final supabase = Supabase.instance.client;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final currentTime = DateTime.now().toUtc();
    await supabase.from('product_table').insert({
      'image': imageUrl,
      'userId': currentUserId,
      'name': productName,
      'description': productContent,
      'price': productPrice,
      'product_link': productLink,
      'created_at': currentTime.toIso8601String()
    });
  }
}
