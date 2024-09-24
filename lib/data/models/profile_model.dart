import 'dart:convert';

class ProfileData {
  final String uid;
  final String name;
  final String email;
  final String profile_img;
  final String? homeLoc;
  final String? officeDetails;
  final List<String>? passions;
  final List<String>? images;
  final Map<String, String>? socialmedia;

  ProfileData(
      {required this.uid,
      required this.name,
      required this.profile_img,
      this.homeLoc,
      required this.email,
      this.officeDetails,
      this.passions,
      this.socialmedia,
      required this.images});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      uid: json['id'] ?? 'null',
      images: (json['images'] != null && json['images'].isNotEmpty)
          ? List<String>.from(json['images'])
          : [],
      name: json['name'] ?? 'Unknown',
      profile_img: (json['images'] != null && json['images'].isNotEmpty)
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
