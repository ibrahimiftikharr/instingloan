import 'package:flutter/material.dart';

void scaffold(String msg, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
