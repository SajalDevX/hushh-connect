class Product {
  final String productname;
  final String productImageUrl;
  final String productPrice;
  final String productContent;
  Product(
      {required this.productImageUrl,
      required this.productname,
      required this.productContent,
      required this.productPrice});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productname: json['name'] ?? '',
      productContent: json['description'] ?? '',
      productPrice: json['price'] ?? '',
      productImageUrl: json['image'] ?? '',
    );
  }
}
