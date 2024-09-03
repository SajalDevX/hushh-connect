import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Customtextbox extends StatelessWidget {
  final TextInputType keyboardType;
  final int maxLength;
  final String hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final double height;
  final TextEditingController? controller;
  final String? errorText;

  const Customtextbox({
    super.key,
    this.keyboardType = TextInputType.text,
    this.maxLength = 50,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.height = 56,
    this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            inputFormatters: [
              if (keyboardType == TextInputType.number)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.blueGrey),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
            style:
                const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
