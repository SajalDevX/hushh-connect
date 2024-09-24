import 'dart:convert';

class ProfileData {
  final String name;
  final String email;
  final String imageurl;
  final String? homeLoc;
  final String? officeDetails;
  final List<String>? passions;
  final Map<String, String>? socialmedia;

  ProfileData({
    required this.name,
    required this.imageurl,
    this.homeLoc,
    required this.email,
    this.officeDetails,
    this.passions,
    this.socialmedia,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] ?? 'Unknown',
      imageurl: (json['images'] != null && json['images'].isNotEmpty)
          ? List<String>.from(json['images'])[0]
          : '',
      email: json['email'] ?? 'Unknown',
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
