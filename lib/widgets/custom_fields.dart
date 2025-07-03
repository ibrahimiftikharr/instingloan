import 'package:flutter/material.dart';

Widget CustomField(String hint, bool hide, TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: hide,
    decoration: InputDecoration(
      hintText: hint,

      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.lightGreen, width: 2),
      ),
    ),
  );
}

Widget myFormField(
    String hint,
    TextEditingController controller,
    TextInputType inputType,
  ) {
  return  TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          filled: true,
          fillColor: Color(0xFFF4F4F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );
}