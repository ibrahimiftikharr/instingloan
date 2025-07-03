import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

Widget myPoppinText(String text, FontWeight weight, double size) {
  return Text(
    text,
    style: GoogleFonts.poppins(fontWeight: weight, fontSize: size),
  );
}
