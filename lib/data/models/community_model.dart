class Community {
  final int id;
  final String name;
  final String description;
  final String image;
  final DateTime createdAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.createdAt,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
