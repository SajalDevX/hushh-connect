class Product {
  final String productname;
  final String productImageUrl;
  final String productPrice;
  final String productContent;
  final String link;
  Product(
      {required this.productImageUrl,
      required this.productname,
      required this.productContent,
      required this.productPrice,
      required this.link});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productname: json['name'] ?? '',
      link: json['product_link'] ?? '',
      productContent: json['description'] ?? '',
      productPrice: json['price'] ?? '',
      productImageUrl: json['image'] ?? '',
    );
  }
}
