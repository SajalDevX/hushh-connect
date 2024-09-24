import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hushhxtinder/ui/app/profile/profileViewModel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _tasksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profile = await profileViewModel.fetchUser();
      if (profile != null) {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
        if (profile.officeDetails != null) {
          final officeDetails = profileViewModel.profile?.officeDetails != null
              ? Map<String, dynamic>.from(
                  json.decode(profileViewModel.profile!.officeDetails!))
              : null;
          _roleController.text = officeDetails?['role'] ?? '';
          _companyController.text = officeDetails?['company'] ?? '';
          _tasksController.text = officeDetails?['tasks'] ?? '';
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _tasksController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);

    final success = await profileViewModel
        .editUserProfile(_nameController.text, _emailController.text, {
      'role': _roleController.text,
      'company': _companyController.text,
      'tasks': _tasksController.text,
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context); // Go back after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Edit Profile',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField('Name', _nameController, 1),
                          const SizedBox(height: 16),
                          _buildTextField('Email', _emailController, 1),
                          const SizedBox(height: 16),
                          _buildTextField('Company', _companyController, 1),
                          const SizedBox(height: 16),
                          _buildTextField('Role', _roleController, 1),
                          const SizedBox(height: 16),
                          _buildTextField('Tasks', _tasksController, 5),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: IAgreeButton(
                      text: 'Save Profile',
                      onPressed: _saveProfile,
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

  Widget _buildTextField(
      String label, TextEditingController controller, int? maxLines) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
