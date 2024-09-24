import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hushhxtinder/ui/app/product/productViewmodel.dart';

class AddProductScreen extends StatefulWidget {
  final VoidCallback onProductAdded;

  const AddProductScreen({super.key, required this.onProductAdded});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _productNameController = TextEditingController();
  final _productLinkController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productContentController = TextEditingController();

  File? _productImage;
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _productImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_productImage == null ||
        _productNameController.text.isEmpty ||
        _productContentController.text.isEmpty ||
        _productPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    final viewModel = Provider.of<Productviewmodel>(context, listen: false);
    final double? price = double.tryParse(_productPriceController.text);

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await viewModel.uploadProduct(
        imageFile: _productImage!,
        productName: _productNameController.text,
        productContent: _productContentController.text,
        productPrice: price,
        productLink: _productLinkController.text,
      );
      widget.onProductAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Add Product",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _productImage == null
                        ? Container(
                            height: screenHeight * 0.25,
                            color: Colors.grey[200],
                            child: const Center(
                                child: Text('Tap to select image')),
                          )
                        : Image.file(_productImage!,
                            height: screenHeight * 0.35),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "PRODUCT INFORMATION",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField("Product Name", _productNameController, 1),
                  _buildTextField("Product Link", _productLinkController, 1),
                  _buildTextField("Price", _productPriceController, 1),
                  _buildTextField("Content", _productContentController, 5),
                  SizedBox(
                    width: double.infinity,
                    child: IAgreeButton(
                      onPressed: _saveProduct,
                      text: "Add Product",
                      size: screenHeight * 0.06,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, int maxLines) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: screenWidth * 0.045),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 105, 30, 233), width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 138, 30, 233), width: 2.0),
          ),
        ),
      ),
    );
  }
}
