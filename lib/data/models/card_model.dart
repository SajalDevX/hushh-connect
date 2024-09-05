class ImageData {
  final String imageRes;
  final String name;
  final String role;
  final String companyName;
  final String location;
  final String description;
  final String contactNumber;
  final List<dynamic> products;
  final List<dynamic> passions;
  final String instagram;
  final String linkedin;
  final String twitter;
  final String youtube;
  final String otherlink;
  final String userId;

  ImageData(
      {required this.imageRes,
      required this.name,
      required this.role,
      required this.companyName,
      required this.location,
      required this.description,
      required this.contactNumber,
      required this.products,
      required this.passions,
      required this.instagram,
      required this.linkedin,
      required this.twitter,
      required this.youtube,
      required this.otherlink,
      required this.userId});
}

class CardData {
  final List<List<ImageData>> cards;

  CardData(this.cards);
}
