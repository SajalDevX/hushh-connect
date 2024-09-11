import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hushhxtinder/ui/app/product/addProductScreen.dart';
import 'package:hushhxtinder/ui/app/product/productViewmodel.dart';
import 'package:hushhxtinder/ui/components/productCard.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final productViewModel =
        Provider.of<Productviewmodel>(context, listen: false);
    await productViewModel.fetchProducts();
  }

  void _onProductAdded() async {
    // Refresh the product list when a product is added
    await _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // IconButton(
                    //   icon: const Icon(Icons.arrow_back, color: Colors.white),
                    //   onPressed: () {
                    //     Navigator.pop(context);
                    //   },
                    // ),
                    SvgPicture.asset(
                      "lib/assets/images/huash_logo_2.svg",
                      height: 28,
                      width: 28,
                      fit: BoxFit.contain,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Image.asset(
                          "lib/assets/images/notify_topbar.png",
                          height: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 32.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Products",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddProductScreen(
                                  onProductAdded: _onProductAdded,
                                ),
                              ),
                            );
                          },
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xffe54d60),
                                Color(0xffa342ff)
                              ], // Define your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(Rect.fromLTWH(
                                0, 0, bounds.width, bounds.height)),
                            child: const Text(
                              "Add new",
                              style: TextStyle(
                                color: Colors
                                    .white, // This color is used as a fallback
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<Productviewmodel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (viewModel.products.isEmpty) {
                          return const Center(
                            child: Text(
                              'No products available',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          return GridView.builder(
                            itemCount: viewModel.products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.7, // Adjusted for better fit
                            ),
                            itemBuilder: (context, index) {
                              return ProductCard(
                                  product: viewModel.products[index]);
                            },
                          );
                        }
                      },
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
}
