import 'dart:convert';

class ProfileData {
  final String name;
  final String imageurl;
  final String? homeLoc; // Home location in string format
  final String? officeDetails; // Office details as a JSON object
  final List<String>? passions; // List of passions
  final Map<String, String>? socialmedia; // Social media links as a JSON object

  ProfileData({
    required this.name,
    required this.imageurl,
    this.homeLoc,
    this.officeDetails,
    this.passions,
    this.socialmedia,
  });

  // Optional: Add factory method for easier JSON parsing
  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] ?? 'Unknown',
      imageurl: (json['images'] != null && json['images'].isNotEmpty)
          ? List<String>.from(json['images'])[0]
          : '',
      homeLoc: json['current_address'] as String?,
      officeDetails: json['office_details'] != null
          ? jsonEncode(json['office_details'])
          : null,
      passions:
          json['passions'] != null ? List<String>.from(json['passions']) : null,
      socialmedia: json['socialmedia'] != null
          ? Map<String, String>.from(json['socialmedia'])
          : null,
    );
  }
}
