import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushhxtinder/data/models/productModel.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(Object context) {
    return Container(
      height: 256,
      width: double.infinity,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            child: Image.network(
              product.productImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.productname,
                  style: GoogleFonts.figtree(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                SizedBox(height: 4.0),
                Text(
                  product.productContent,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                SizedBox(height: 8.0),
                Text(
                  '\$${product.productPrice.toString()}',
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
